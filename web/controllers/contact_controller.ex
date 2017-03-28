defmodule CercleApi.ContactController do
  use CercleApi.Web, :controller
  use Timex

  alias CercleApi.{Contact,Organization,TimelineEvent,Activity,Company,ContactTag,Tag,Board}

  require Logger

  plug :authorize_resource, model: Contact, only: [:show], 
  unauthorized_handler: {CercleApi.Helpers, :handle_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_not_found}


  def index(conn, params) do

    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload([:users])

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
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload([:users])

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
    contact = Repo.preload(Repo.get!(Contact, params["id"]), [:organization, :company, :tags])
    company = Repo.preload(Repo.get!(CercleApi.Company, contact.company_id), [:users])
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
    activities = Repo.all(query) |> Repo.preload([:user])

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

      query1 = from event in CercleApi.TimelineEvent,
      where: event.opportunity_id == ^opportunity.id,
      order_by: [desc: event.inserted_at]
      events = Repo.all(query1) |> Repo.preload([:user])
    end

    query = from p in Board,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

    boards = Repo.all(query)  |> Repo.preload(board_columns: from(CercleApi.BoardColumn, order_by: [asc: :order]))

    query1 = from p in Tag,
      where: p.company_id == ^company_id
    tags = Repo.all(query1)

    tag_ids = Enum.map(contact.tags, fn(t) -> t.id end)

    changeset = Contact.changeset(contact)
    conn
    |> put_layout("adminlte.html")
    |> render("show.html", opportunities: opportunities, activities: activities, opportunity: opportunity, contact: contact, changeset: changeset, company: company, events: events, organizations: organizations, opportunity_contacts: opportunity_contacts, tags: tags, tag_ids: tag_ids, board: board, boards: boards)
  end

  def import(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload([:users])

    conn
      |> put_layout("adminlte.html")
      |> render("import.html", company: company, company_id: company_id)
  end

  def import_data(conn, %{"file" => file_params}) do

    upload = file_params
    extension = Path.extname(upload.filename)
    temp_file = UUID.uuid1()
    unless File.dir?("tmp") do
      File.mkdir!("tmp")
    end
    File.cp!(upload.path,"tmp/#{temp_file}.csv")
    {:ok, table} = File.read!("tmp/#{temp_file}.csv") |> ExCsv.parse(headings: true)
    table_rows = Enum.count(table.body)
    if table_rows > 10_000 do
      File.rm!("tmp/#{temp_file}.csv")
      json conn, %{error_message: "Maximum 10,000 records are permitted"}
    else
      headers = table.headings
      first_row = Enum.at(table.body, 0)
      top_five_rows = Enum.take(table.body,5)
      contact_fields = ["name","email","description","phone","job_title"]
      organization_fields = ["name","website","description"]
      json conn, %{headers: headers, first_row: first_row, top_five_rows: top_five_rows, contact_fields: contact_fields, organization_fields: organization_fields, temp_file: temp_file}
    end
  end

  def view_uploaded_data(conn, %{"mapping" => mapping, "temp_file" => temp_file}) do

    table = File.read!("tmp/#{temp_file}.csv") |> ExCsv.parse! |> ExCsv.with_headings |> Enum.to_list
    total_rows = Enum.count(table) - 1
    contact_headers = Map.keys(mapping["contact"])
    organization_headers = Map.keys(mapping["organization"])
    first_row = Enum.at(table, 0)
    contact_values = for {db_col,csv_col} <- mapping["contact"] do
      first_row[csv_col]
    end
    organization_values = for {db_col,csv_col} <- mapping["organization"] do
      first_row[csv_col]
    end
    json conn, %{contact_headers: contact_headers, organization_headers: organization_headers, contact_values: contact_values, organization_values: organization_values,  temp_file: temp_file}
  end

  def create_nested_data(conn, %{"mapping" => mapping, "temp_file" => temp_file}) do

    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    table = File.read!("tmp/#{temp_file}.csv") |> ExCsv.parse! |> ExCsv.with_headings |> Enum.to_list
    total_rows = Enum.count(table) - 1
    iterations = div(total_rows,100)
    datetime = Timezone.convert(Timex.now,user.time_zone)
    date = Timex.format!(datetime, "%m/%d/%Y", :strftime)
    time = Timex.format!(datetime, "%H:%M", :strftime)
    tag_name = "imported #{date} at #{time}"
    tag_id = Repo.insert!(%Tag{name: tag_name, company_id: company_id}).id
    str_tag_id = Integer.to_string(tag_id)
    responses  = for n <- 0..iterations do
      lower..upper = (n * 100..(n + 1) * 100 -1)
      if upper > total_rows do upper = total_rows end
      items = for i <- lower..upper do
        row_data = %{}
        selected_row = Enum.at(table, i)
        contact_data = %{"name" => selected_row[mapping["contact"]["name"]], "email" => selected_row[mapping["contact"]["email"]], "phone" => selected_row[mapping["contact"]["phone"]], "description" => selected_row[mapping["contact"]["description"]], "job_title" => selected_row[mapping["contact"]["job_title"]]}
        organization_data = %{"name" => selected_row[mapping["organization"]["name"]], "website" => selected_row[mapping["organization"]["website"]],"description" => selected_row[mapping["organization"]["description"]]}
        Map.put(row_data, "contact", contact_data) |> Map.put("organization", organization_data)
      end
      contacts = CercleApi.APIV2.BulkController.bulk_contact_create(conn,%{"items" => items, "return" => true})
      CercleApi.APIV2.BulkController.bulk_tag_or_untag_contacts(conn,%{"contacts" => contacts, "tag_id" => str_tag_id, "untag" => false, "return" => true})
    end
    File.rm!("tmp/#{temp_file}.csv")
    json conn, %{status: "200", message: "Records imported successfully"}
  end

end
