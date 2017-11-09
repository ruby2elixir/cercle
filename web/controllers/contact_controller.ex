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
    company = conn
    |> current_company
    |> Repo.preload([:users])

    if params["tag_name"] do
      tag_name = params["tag_name"]
      contacts = Repo.all(from a in Contact,
        preload: [:tags],
        left_join: ac in ContactTag, on: a.id == ac.contact_id,
        left_join: c in Tag, on: c.id == ac.tag_id,
        where: like(c.first_name, ^tag_name) or like(c.last_name, ^tag_name)
        )
      leads_pending = contacts
      |> Repo.preload([
        :organization, :tags,
        timeline_event: from(TimelineEvent, order_by: [desc: :inserted_at])]
      )
    else
      query = from p in Contact,
        where: p.company_id == ^company.id,
        order_by: [desc: p.updated_at]

      leads_pending = query
      |> Repo.all
      |> Repo.preload([
        :organization, :tags,
        timeline_event: from(TimelineEvent, order_by: [desc: :inserted_at])]
      )

    end

    conn
    |> put_layout("adminlte.html")
    |> render("index.html", leads_pending: leads_pending , company: company, page: :contacts)
  end

  def new(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = conn
    |> current_company
    |> Repo.preload([:users])

    query = from p in Board,
      where: p.company_id == ^company.id,
      order_by: [desc: p.updated_at]

    boards = query
    |> Repo.all
    |> Repo.preload(board_columns: from(BoardColumn, order_by: [asc: :order]))

    conn
    |> put_layout("adminlte.html")
    |> render("new.html", company: company, boards: boards)
  end

  def show(conn, params) do
    user = Guardian.Plug.current_resource(conn)
    company = conn
    |> current_company
    |> Repo.preload([:users])
    contact = Repo.preload(Repo.get!(Contact, params["id"]), [:organization, :company, :tags])
    if contact.company_id != company.id do
      conn |> redirect(to: "/") |> halt
    end
    conn
    |> put_layout("adminlte.html")
    |> render("show.html", contact: contact)
  end
end
