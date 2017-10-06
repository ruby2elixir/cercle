defmodule CercleApi.APIV2.ContactController do
  require Logger
  use CercleApi.Web, :controller
  use Timex

  alias CercleApi.{Repo, Contact, Company, Tag, ContactTag, TimelineEvent, Card,
                   CardService, ContactService}

  plug CercleApi.Plug.EnsureAuthenticated
  plug CercleApi.Plug.CurrentUser

  plug :scrub_params, "contact" when action in [:create, :update]

  plug :authorize_resource, model: Contact, only: [:update, :delete, :show],
    unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
    not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, params) do
    q = params["q"]
    current_user = CercleApi.Plug.current_user(conn)
    company = current_company(conn)
    query = from p in Contact,
      where: p.company_id == ^company.id,
      where: ilike(p.first_name, ^("%#{q}%")) or ilike(p.last_name, ^("%#{q}%")),
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
    user = CercleApi.Plug.current_user(conn)
    company = current_company(conn)
    contact_params = contact_params
    |> Map.merge(split_name(contact_params))
    |> Map.put("user_id", user.id)

    changeset = company
      |> Ecto.build_assoc(:contacts)
      |> Contact.changeset(contact_params)

    case Repo.insert(changeset) do
      {:ok, contact} ->
        contact = contact
        |> Repo.preload(
          [:organization, :tags, company: [:users, boards: [:board_columns]]]
        )
        |> Contact.preload_cards
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
    |> Contact.preload_cards
    render(conn, "index.json", contacts: contacts)
  end

  def show(conn, %{"id" => id}) do
    contact = Contact
    |> Contact.preload_data
    |> Repo.get(id)
    |> Contact.preload_cards

    render(conn, "full_contact.json", contact: contact)
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Repo.get!(Contact, id)

    if contact_params["data"] do
      new_data = Map.merge(contact.data , contact_params["data"])
      contact_params = %{contact_params | "data" => new_data}
    end

    contact_params = Map.merge(contact_params, split_name(contact_params))
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
    delete_contact(contact)

    json conn, %{status: 200}
  end

  # multiple delete contacts
  #
  def multiple_delete(conn, %{"contact_ids" => contact_ids}) do
    current_user = CercleApi.Plug.current_user(conn)
    company = current_company(conn)

    query = from c in Contact,
      where: c.company_id == ^company.id,
      where: c.id in ^contact_ids
    contacts = Repo.all(query)

    for contact <- contacts, do: delete_contact(contact)
    json conn, %{status: 200}
  end

  defp split_name(%{"name" => name} = contact_params) when is_binary(name) do
    if String.trim(to_string(contact_params["last_name"])) == "" do
      name_splits = String.split(name, ~r/\s+/)
      if length(name_splits) == 1 do
        [last_name] = name_splits
        %{"last_name" => last_name}
      else
        [first_name|name_splits] = name_splits
        last_name = Enum.join(name_splits, " ")
        %{"first_name" => first_name, "last_name" => last_name}
      end
    else
      %{}
    end
  end
  defp split_name(_contact_params), do: %{}

  defp delete_contact(contact) do

    cards = Contact.cards(contact)

    for op <- cards do
      contact_ids = List.delete(op.contact_ids, contact.id)
      case length(contact_ids) do
        0 ->
          Repo.delete!(op)
          CardService.delete(op)
        _ ->
          changeset = Card.changeset(op, %{contact_ids: contact_ids})
          Repo.update(changeset)
      end
    end

    Repo.delete!(contact)
    ContactService.delete(contact)
  end
end
