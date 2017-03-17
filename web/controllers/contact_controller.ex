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

end
