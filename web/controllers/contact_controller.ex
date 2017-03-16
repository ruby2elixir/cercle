defmodule CercleApi.ContactController do
  use CercleApi.Web, :controller

  alias CercleApi.Contact
  alias CercleApi.Organization
  alias CercleApi.TimelineEvent
  alias CercleApi.Activity
  alias CercleApi.Company
  alias CercleApi.ContactTag
  alias CercleApi.Tag
  alias CercleApi.Board
  alias CercleApi.CsvUpload

	require Logger

  def index(conn, params) do

    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    if params["tag_name"] do
      tag_name = params["tag_name"] 
      contacts = Repo.all(from a in Contact,
        preload: [:tags],
        left_join: ac in ContactTag, on: a.id == ac.contact_id,
        left_join: c in Tag, on: c.id == ac.tag_id,
        where: like(c.name, ^tag_name)
        )
      leads_pending = contacts  |> Repo.preload([:organization, :tags, timeline_event: from(CercleApi.TimelineEvent, order_by: [desc: :inserted_at])])
    else
      query = from p in Contact,
        where: p.company_id == ^company_id,
        order_by: [desc: p.updated_at]

      leads_pending = Repo.all(query)   |> Repo.preload([:organization, :tags, timeline_event: from(CercleApi.TimelineEvent, order_by: [desc: :inserted_at])])

    end
		conn
		|> put_layout("adminlte.html")
		|> render("index.html", leads_pending: leads_pending , company: company)
  end

  def new(conn, _params) do
    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    query = from p in Board,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

    boards = Repo.all(query)  |> Repo.preload(board_columns: from(CercleApi.BoardColumn, order_by: [asc: :order]))

    conn
    |> put_layout("adminlte.html")
    |> render("new.html", company: company, boards: boards)
  end

  def show(conn, params) do
    
    company_id = conn.assigns[:current_user].company_id
    contact = Repo.get!(Contact, params["id"]) |> Repo.preload([:organization, :company, :tags])
    company = Repo.get!(CercleApi.Company, contact.company_id) |> Repo.preload([:users])
    if contact.company_id != company_id do 
      conn |> redirect(to: "/") |> halt
    end
    query = from p in Organization,
      where: p.company_id == ^company_id,
      order_by: [desc: p.inserted_at]
    organizations = Repo.all(query)

    
    query = from activity in CercleApi.Activity,
      where: activity.contact_id == ^contact.id,
      where: activity.is_done == false,
      order_by: [desc: activity.inserted_at]
    activities = Repo.all(query) |> Repo.preload [:user]

    query = from opportunity in CercleApi.Opportunity,
      where: fragment("? = ANY (?)", ^contact.id, opportunity.contact_ids),
      order_by: [desc: opportunity.inserted_at]
    opportunities = Repo.all(query)
    
    if params["opportunity_id"] do
      opportunity = Repo.get!(CercleApi.Opportunity, params["opportunity_id"]) 
    else
      query = from opportunity in CercleApi.Opportunity,
        where: fragment("? = ANY (?)", ^contact.id, opportunity.contact_ids),
        where: opportunity.status == 0,
        order_by: [desc: opportunity.inserted_at]
      opportunities = Repo.all(query)
      opportunity = List.first(opportunities)
    end
    
    events = []

    if opportunity do
      contact_ids = opportunity.contact_ids
      query = from contact in CercleApi.Contact,
        where: contact.id in ^contact_ids
      opportunity_contacts = Repo.all(query)

      board = Repo.get!(CercleApi.Board, opportunity.board_id)  |> Repo.preload(board_columns: from(CercleApi.BoardColumn, order_by: [asc: :order]))

      query = from event in CercleApi.TimelineEvent,
      where: event.opportunity_id == ^opportunity.id,
      order_by: [desc: event.inserted_at]
      events = Repo.all(query) |> Repo.preload [:user]
    end

    query = from p in Board,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

    boards = Repo.all(query)  |> Repo.preload(board_columns: from(CercleApi.BoardColumn, order_by: [asc: :order]))

    query = from p in Tag,
      where: p.company_id == ^company_id
    tags = Repo.all(query)

    tag_ids = Enum.map(contact.tags, fn(t) -> t.id end)


    changeset = Contact.changeset(contact)
		conn
		|> put_layout("adminlte.html")
		|> render("show.html", opportunities: opportunities, activities: activities, opportunity: opportunity, contact: contact, changeset: changeset, company: company, events: events, organizations: organizations, opportunity_contacts: opportunity_contacts, tags: tags, tag_ids: tag_ids, board: board, boards: boards)
  end

  def import(conn, _params) do
    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    conn
      |> put_layout("adminlte.html")
      |> render("import.html", company: company, company_id: company_id)
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
    end    
  end

  def view_uploaded_data(conn, %{"mapping" => mapping, "s3Url" => s3_url}) do

    %HTTPoison.Response{body: body, status_code: status_code} = HTTPoison.get!(s3_url)
    file_name = UUID.uuid1()
    unless File.dir?("tmp") do
      File.mkdir!("tmp")
    end
    File.write!("tmp/#{file_name}.csv", body)
    table = File.read!("tmp/#{file_name}.csv") |> ExCsv.parse! |> ExCsv.with_headings |> Enum.to_list
    contact_headers = Map.keys(mapping["contact"])
    organization_headers = Map.keys(mapping["organization"])
    first_row = Enum.at(table, 0)
    contact_values = for {db_col,csv_col} <- mapping["contact"] do
      first_row[csv_col]
    end
    organization_values = for {db_col,csv_col} <- mapping["organization"] do
      first_row[csv_col]
    end
    json conn, %{contact_headers: contact_headers, organization_headers: organization_headers, contact_values: contact_values, organization_values: organization_values,  file_name: file_name}
  end

  def create_nested_data(conn, %{"mapping" => mapping, "fileName" => file_name, "companyId" => company_id, "userId" => user_id, "s3Url" => s3_url}) do
    unless File.exists?("tmp/#{file_name}.csv") do
      %HTTPoison.Response{body: body, status_code: status_code} = HTTPoison.get!(s3_url)
      file_name = UUID.uuid1()
      unless File.dir?("tmp") do
        File.mkdir!("tmp")
      end
      File.write!("tmp/#{file_name}.csv", body)
    end
    table = File.read!("tmp/#{file_name}.csv") |> ExCsv.parse! |> ExCsv.with_headings |> Enum.to_list
    total_rows = Enum.count(table)-1

    items = for i <- 0..total_rows do
      row_data = %{}
      selected_row = Enum.at(table, i)
      contact_data = %{"user_id" => user_id,"company_id" => company_id ,"name" => selected_row[mapping["contact"]["name"]], "email" => selected_row[mapping["contact"]["email"]], "phone" => selected_row[mapping["contact"]["phone"]], "description" => selected_row[mapping["contact"]["description"]], "job_title" => selected_row[mapping["contact"]["job_title"]]}
      row_data = Map.put(row_data, "contact", contact_data)
      organization_data = %{"name" => selected_row[mapping["organization"]["name"]], "website" => selected_row[mapping["organization"]["website"]],"description" => selected_row[mapping["organization"]["description"]]}
      row_data = Map.put(row_data, "organization", organization_data)
      row_data
    end
    File.rm!("tmp/#{file_name}.csv")
    CercleApi.APIV2.ContactController.bulk_contact_create(conn,%{"items" => items})
  end
end
