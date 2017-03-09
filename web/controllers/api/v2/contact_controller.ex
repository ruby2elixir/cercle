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
  alias CercleApi.CsvUpload

  plug :scrub_params, "contact" when action in [:create, :update]

  def index(conn, _params) do
    contacts = Repo.all(Contact)
    render(conn, "index.json", contacts: contacts)
  end

  def create(conn, %{"contact" => contact_params}) do
    
    contact_params = sub_contact_function(conn,contact_params)
    changeset = Contact.changeset(%Contact{}, contact_params)
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

  def import_data(conn, %{"file" => file_params, "company_id" => company_id}) do

    upload = file_params
    file_name = upload.filename
    extension = Path.extname(upload.filename)
    file_path = upload.path
    case CsvUpload.store({file_params, company_id}) do
      {:ok, path} ->
        s3_path = CsvUpload.url({path,company_id})
        {:ok, table} = File.read!(Path.expand(file_path)) |> ExCsv.parse(headings: true)
        headers = table.headings
        first_row = Enum.at(table.body, 0)
        contact_fields = ["name","email","description","phone","job_title"]
        organization_fields = ["name","website","description"]
        json conn, %{headers: headers, first_row: first_row, contact_fields: contact_fields, organization_fields: organization_fields, s3_url: s3_path}
      {:error, reason} ->
        json conn, %{error: reason}
      _ -> 
        IO.inspect "Default"
    end    
  end

  def view_uploaded_data(conn, %{"mapping" => mapping, "s3_url" => s3_url}) do

    %HTTPoison.Response{body: body, status_code: status_code} = HTTPoison.get!(s3_url)
    file_name = UUID.uuid1()
    unless File.dir?("tmp") do
      File.mkdir!("tmp")
    end
    File.write!("tmp/#{file_name}.csv", body)
    table = File.read!("tmp/#{file_name}.csv") |> ExCsv.parse! |> ExCsv.with_headings |> Enum.to_list
    headers = Map.keys(mapping)
    first_row = Enum.at(table, 0)
    preview_values = []
    preview_values = for {db_col,csv_col} <- mapping do
      first_row[csv_col]
    end
    json conn, %{headers: headers, mapping: preview_values, file_name: file_name}
  end

  def contact_create(conn, %{"mapping" => mapping, "file_name" => file_name, "company_id" => company_id, "user_id" => user_id}) do

    user = Repo.get(User,user_id)
    contact_params = %{"company_id" => company_id, "organization_id" => "", "user_id" => user_id}
    table = File.read!("tmp/#{file_name}.csv") |> ExCsv.parse! |> ExCsv.with_headings |> Enum.to_list
    File.rm!("tmp/#{file_name}.csv")

    total_rows = Enum.count(table)-1

    for i <- 0..total_rows do
      first_row = Enum.at(table, i)
      # find only mapped values from csv
      maps = for {db_col,csv_col} <- mapping do
        maps = %{db_col => first_row[csv_col]}
      end
      contact_params = Enum.reduce(maps, contact_params, fn (map, acc) -> Map.merge(acc, map) end)
      #call sub function for creating contacts
      contact_params = sub_contact_function(conn,contact_params)
      changeset = Contact.changeset(%Contact{}, contact_params)
      case Repo.insert(changeset) do
        {:ok, contact} ->
          
          #create tags
          contact = Repo.get!(Contact, contact.id) 
          query = from c in ContactTag,
            where: c.contact_id == ^contact.id
          Repo.delete_all(query)
          {company_id, _rest} = Integer.parse(company_id)
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
          case Repo.update(changeset) do
            {:ok, contact} ->
              render(conn, "show.json", contact: contact)
            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
          end
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
      end
    end
  end

  def sub_contact_function(conn,contact_params) do
    company_id = contact_params["company_id"]
    if contact_params["email"] do 
      domain_email = List.first(Enum.take(String.split(contact_params["email"], "@"), -1))

      query = from organization in Organization,
        where: organization.website == ^domain_email,
        where: organization.company_id == ^company_id
  
      organizations = Repo.all(query)
  
      if Enum.count(organizations) == 0 do
        organization_params = %{"name" => domain_email, "website" => domain_email, "company_id" => company_id}
        changeset = Organization.changeset(%Organization{}, organization_params)
        case Repo.insert(changeset) do
          {:ok, org} ->
            organization_id = org.id
        end
      end
  
      organizations = Repo.all(query)
      organization = Enum.at(organizations, 0)
      organization_id = organization.id
      contact_params = %{contact_params | "organization_id" => organization_id}
    end
  end
end