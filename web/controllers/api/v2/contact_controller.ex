defmodule CercleApi.APIV2.ContactController do
  require Logger
  use CercleApi.Web, :controller
  use Timex

  alias CercleApi.{Repo, Contact, Company, Tag, ContactTag, TimelineEvent, Opportunity, OpportunityService, ContactService}

  plug Guardian.Plug.EnsureAuthenticated
  plug CercleApi.Plugs.CurrentUser

  plug :scrub_params, "contact" when action in [:create, :update]

  plug :authorize_resource, model: Contact, only: [:update, :delete, :show],
    unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
    not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, params) do
    q = params["q"]
    current_user = Guardian.Plug.current_resource(conn)
    company_id  = current_user.company_id
    query = from p in Contact,
      where: p.company_id == ^company_id,
      where: ilike(p.name, ^("%#{q}%")),
      order_by: [desc: p.updated_at]

    contacts = query
    |> Repo.all
    |> Repo.preload(
      [ :organization, :tags,
        timeline_event: from(TimelineEvent, order_by: [desc: :inserted_at])
      ]
    )

    render(conn, "index.json", contacts: contacts)
  end

  def create(conn, %{"contact" => contact_params}) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get!(Company, user.company_id)
    contact_params = Map.put(contact_params, "user_id", user.id) 

    changeset = company
      |> Ecto.build_assoc(:contacts)
      |> Contact.changeset(contact_params)

    case Repo.insert(changeset) do
      {:ok, contact} ->
        contact = contact
        |> Repo.preload(
          [:organization, :tags, :opportunities,
           company: [:users, boards: [:board_columns]]]
        )
        ContactService.insert(contact)
        conn
        |> put_status(:created)
        |> render("show.json", contact: contact)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"user_id" => user_id, "company_id" => company_id}) do
    query = from contact in Contact,
      where: contact.user_id == ^user_id and contact.company_id == ^company_id,
      order_by: [desc: contact.id]
    contacts = query
    |> Contact.preload_data
    |> Repo.all
    render(conn, "index.json", contacts: contacts)
  end

  def show(conn, %{"id" => id}) do
    contact = Contact
    |> Contact.preload_data
    |> Repo.get(id)

    render(conn, "full_contact.json", contact: contact)
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Repo.get!(Contact, id)
    if contact_params["data"] do
      new_data = Map.merge(contact.data , contact_params["data"])
      contact_params = %{contact_params | "data" => new_data}
    end
    changeset = Contact.changeset(contact, contact_params)

    case Repo.update(changeset) do
      {:ok, contact} ->
        contact = contact |> Repo.preload([:tags, :organization])
        channel = "contacts:"  <> to_string(contact.id)

        CercleApi.Endpoint.broadcast!(channel, "update", %{
              contact: contact,
              organization: (contact.organization || %{})})

        ContactService.update(contact)
        render(conn, "show.json", contact: contact)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def utags(conn, %{"id" => id, "company_id" => _company_id_string}) do
    contact = Repo.get!(Contact, id)
    |> Repo.preload([:tags, :organization])
    query = from c in ContactTag,
      where: c.contact_id == ^id
    Repo.delete_all(query)
    channel = "contacts:"  <> to_string(contact.id)
    CercleApi.Endpoint.broadcast!(channel, "update", %{contact: contact, tags: []})
    render(conn, "show.json", contact: contact)
  end

  def update_tags(conn, %{"id" => id, "tags" => tag_params, "company_id" => company_id}) do
    contact = Repo.get!(Contact, id)
    |> Repo.preload([:organization])

    #tag_params
    query = from c in ContactTag,
        where: c.contact_id == ^id
      Repo.delete_all(query)

    if tag_params == "" do
      render(conn, "show.json", contact: contact)
    else
      tag_ids = Enum.map tag_params, fn tag ->
        cond do
          is_number(tag) -> tag
          Regex.run(~r/^[\d]+$/, tag) ->
            {tag_id, _rest} = Integer.parse(tag)
            tag_id
          true ->
          (
            Repo.get_by(Tag, name: tag, company_id: company_id) ||
              Repo.insert!(%Tag{name: tag, company_id: company_id})
          ).id
        end
      end
      query = from tag in Tag,
        where: tag.id in ^tag_ids
      tags = Repo.all(query)
      changeset = contact
        |> Repo.preload(:tags) # Load existing data
        |> Ecto.Changeset.change() # Build the changeset
        |> Ecto.Changeset.put_assoc(:tags, tags) # Set the association

      case Repo.update(changeset) do
        {:ok, contact} ->
          channel = "contacts:"  <> to_string(contact.id)
          CercleApi.Endpoint.broadcast!(channel, "update", %{contact: contact, tags: contact.tags})
          render(conn, "show.json", contact: contact)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    contact = Repo.get!(Contact, id)

    {contact_id, _} = Integer.parse(id)
    query = from o in Opportunity,
      where: fragment("? = ANY (?)", ^contact_id, o.contact_ids)
    opportunities = Repo.all(query)

    for op <- opportunities do
      contact_ids = List.delete(op.contact_ids, contact_id)
      case length(contact_ids) do
        0 ->
          Repo.delete!(op)
          OpportunityService.delete(op)

        _ ->
          if op.main_contact_id == contact_id do
            changeset = Opportunity.changeset(op, %{contact_ids: contact_ids, main_contact_id: Enum.at(contact_ids, 0)})
          else
            changeset = Opportunity.changeset(op, %{contact_ids: contact_ids})
          end
          Repo.update(changeset)
      end
    end

    Repo.delete!(contact)
    ContactService.delete(contact)

    # send_resp(conn, :no_content, "")
    json conn, %{status: 200}
  end

end
