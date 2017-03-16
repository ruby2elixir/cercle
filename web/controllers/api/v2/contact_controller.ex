defmodule CercleApi.APIV2.ContactController do
  require Logger
  use CercleApi.Web, :controller
  use Timex

  alias CercleApi.Contact
  alias CercleApi.Company
  alias CercleApi.Organization
  alias CercleApi.Opportunity
  alias CercleApi.User
  alias CercleApi.Activity
  alias CercleApi.Tag
  alias CercleApi.ContactTag

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "contact" when action in [:create, :update]

  plug Guardian.Plug.EnsureAuthenticated

  def index(conn, _params) do
    contacts = Repo.all(Contact)
    render(conn, "index.json", contacts: contacts)
  end

  def create(conn, %{"contact" => contact_params}) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get!(Company, user.company_id)
    
    changeset = company
      |> Ecto.build_assoc(:contacts)
      |> Contact.changeset(contact_params)
    case Repo.insert(changeset) do
      {:ok, contact} ->
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

    contacts = Repo.all(query)
    render(conn, "index.json", contacts: contacts)
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
        render(conn, "show.json", contact: contact)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update_tags(conn, %{"id" => id, "tags" => tag_params, "company_id" => company_id_string}) do
    contact = Repo.get!(Contact, id)
    {company_id, _rest} = Integer.parse(company_id_string)
    #tag_params
    query = from c in ContactTag,
        where: c.contact_id == ^id
      Repo.delete_all(query)
    
    if tag_params == "" do
      render(conn, "show.json", contact: contact)
    else
      tag_ids = Enum.map tag_params, fn tag ->
        #tag
        if Regex.run(~r/^[\d]+$/, tag) do 
          {tag_id, _rest} = Integer.parse(tag)
          tag_id
        else
          Repo.insert!(%Tag{name: tag, company_id: company_id}).id
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

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(contact)

    send_resp(conn, :no_content, "")
  end

  def bulk_contact_create(conn,%{"items" => items}) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    for item <- items do
      organization_params = Map.put(item["organization"], "company_id", company_id)
      ext_org = Repo.get_by(Organization, name: item["contact"]["name"], company_id: company_id)
      if ext_org do
        contact_params = %{item["contact"] | "organization_id" => ext_org.id}
      else
        changeset = Organization.changeset(%Organization{}, organization_params)
        organization = Repo.insert!(changeset)
        contact_params = Map.put(item["contact"],"organization_id",organization.id)
      end

      changeset = Contact.changeset(%Contact{}, contact_params)
      case Repo.insert(changeset) do
        {:ok, contact} ->          
          #create tags
          contact = Repo.get!(Contact, contact.id) 
          query = from c in ContactTag,
            where: c.contact_id == ^contact.id
          Repo.delete_all(query)
          datetime = Timezone.convert(Ecto.DateTime.to_erl(contact.inserted_at),user.time_zone)
          date = Timex.format!(datetime, "%m/%d/%Y", :strftime)
          time = Timex.format!(datetime, "%H:%M", :strftime)
          tag_name = "imported #{date} at #{time}"
          tag_id = Repo.insert!(%Tag{name: tag_name, company_id: company_id}).id
          query = from tag in Tag,
            where: tag.id == ^tag_id
          tags = Repo.all(query)
              changeset = contact
            |> Repo.preload(:tags) # Load existing data
            |> Ecto.Changeset.change() # Build the changeset
            |> Ecto.Changeset.put_assoc(:tags, tags)
          Repo.update!(changeset)
      end
    end
    json conn, %{status: "200", message: "Records imported successfully"}
  end
end