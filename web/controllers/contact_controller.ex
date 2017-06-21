defmodule CercleApi.ContactController do
  use CercleApi.Web, :controller
  use Timex

  alias CercleApi.{Contact, Organization, TimelineEvent, Activity, Company, ContactTag, Tag, Board, BoardColumn, Card}

  require Logger

  plug :authorize_resource, model: Contact, only: [:show],
  unauthorized_handler: {CercleApi.Helpers, :handle_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_not_found}

  def index(conn, params) do

    user = Guardian.Plug.current_resource(conn)
    company_id = Repo.get!(Company, user.company_id).id
    company = Repo.get!(Company, company_id) |> Repo.preload([:users])

    if params["tag_name"] do
      tag_name = params["tag_name"]
      contacts = Repo.all(from a in Contact,
        preload: [:tags],
        left_join: ac in ContactTag, on: a.id == ac.contact_id,
        left_join: c in Tag, on: c.id == ac.tag_id,
        where: like(c.first_name, ^tag_name) or like(c.last_name, ^tag_name)
        )
      leads_pending = contacts  |> Repo.preload([:organization, :tags, timeline_event: from(TimelineEvent, order_by: [desc: :inserted_at])])
    else
      query = from p in Contact,
        where: p.company_id == ^company_id,
        order_by: [desc: p.updated_at]

      leads_pending = Repo.all(query)   |> Repo.preload([:organization, :tags, timeline_event: from(TimelineEvent, order_by: [desc: :inserted_at])])

    end
    conn
    |> put_layout("adminlte.html")
    |> render("index.html", leads_pending: leads_pending , company: company)
  end

  def new(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = Repo.get!(Company, user.company_id).id
    company = Repo.get!(Company, company_id) |> Repo.preload([:users])

    query = from p in Board,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

    boards = Repo.all(query)  |> Repo.preload(board_columns: from(BoardColumn, order_by: [asc: :order]))

    conn
    |> put_layout("adminlte.html")
    |> render("new.html", company: company, boards: boards)
  end

  def show(conn, params) do

    user = Guardian.Plug.current_resource(conn)
    company_id = Repo.get!(Company, user.company_id).id
    contact = Repo.preload(Repo.get!(Contact, params["id"]), [:organization, :company, :tags])
    company = Repo.preload(Repo.get!(Company, contact.company_id), [:users])
    if contact.company_id != company_id do
      conn |> redirect(to: "/") |> halt
    end
    query = from p in Organization,
      where: p.company_id == ^company_id,
      order_by: [desc: p.inserted_at]
    organizations = Repo.all(query)

    query1 = from activity in Activity,
      where: activity.contact_id == ^contact.id,
      where: activity.is_done == false,
      order_by: [desc: activity.inserted_at]
    activities = Repo.all(query1) |> Repo.preload([:user])

    query2 = from card in Card,
      where: fragment("? = ANY (?)", ^contact.id, card.contact_ids),
      order_by: [desc: card.inserted_at]
    cards = Repo.all(query2)

    if params["card_id"] do
      card = Repo.get!(Card, params["card_id"])
    else
      cards = Repo.all(query2)
      card = nil
    end

    events = []

    if card do
      contact_ids = card.contact_ids
      query = from contact in Contact,
        where: contact.id in ^contact_ids
      card_contacts = Repo.all(query)

      board = Board
      |> Repo.get!(card.board_id)
      |> Repo.preload(board_columns: from(BoardColumn, order_by: [asc: :order]))

      query1 = from event in TimelineEvent,
      where: event.card_id == ^card.id,
      order_by: [desc: event.inserted_at]
      events = Repo.all(query1) |> Repo.preload([:user])
    end

    query3 = from p in Board,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

    boards = Repo.all(query3)  |> Repo.preload(board_columns: from(BoardColumn, order_by: [asc: :order]))

    query4 = from p in Tag,
      where: p.company_id == ^company_id
    tags = Repo.all(query4)

    tag_ids = Enum.map(contact.tags, fn(t) -> t.id end)

    changeset = Contact.changeset(contact)
    conn
    |> put_layout("adminlte.html")
    |> render("show.html", cards: cards, activities: activities, card: card,
    contact: contact, changeset: changeset, company: company, events: events,
    organizations: organizations, card_contacts: card_contacts, tags: tags,
    tag_ids: tag_ids, board: board, boards: boards)
  end
end
