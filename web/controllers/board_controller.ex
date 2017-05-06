defmodule CercleApi.BoardController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Contact, Organization, Opportunity, TimelineEvent, Board, Company}

  require Logger

  plug :authorize_resource, model: Board, only: [:show],
  unauthorized_handler: {CercleApi.Helpers, :handle_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_not_found}

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = Repo.get!(Company, user.company_id).id

    query = from p in Board,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

    boards = Repo.all(query)

    conn
      |> put_layout("adminlte.html")
      |> render "index.html", boards: boards
  end

  def new(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = Repo.get!(Company, user.company_id).id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    conn
      |> put_layout("adminlte.html")
      |> render "new.html", company: company
  end

  def show(conn, %{"id" => id}) do
    board = Repo.get!(CercleApi.Board, id)  |> Repo.preload(board_columns: from(CercleApi.BoardColumn, order_by: [asc: :order]))
    board_id = board.id
    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    query_cards = from p in Opportunity,
        where: p.company_id == ^company_id,
        where: p.board_id == ^board_id,
        where: p.status == 0,
        order_by: [desc: p.updated_at]

    #order_by: [desc: p.rating]
    #from(CercleApi.TimelineEvent], order_by: [desc: :inserted_at])
    query = from a in CercleApi.Activity, 
              where: a.is_done == false,
              preload: :user
    cards = Repo.all(query_cards)  |> Repo.preload([:user, main_contact: [:organization], activities: query, timeline_event: from(CercleApi.TimelineEvent, order_by: [desc: :inserted_at])])

    conn
      |> put_layout("adminlte.html")
      |> render "show.html",  company: company, cards: cards, board: board, no_container: true
  end

  def new(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = Repo.get!(Company, user.company_id).id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    conn
      |> put_layout("app2.html")
      |> render "new.html", company: company
  end

  def edit(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    company_id = Repo.get!(Company, user.company_id).id
    reward = Repo.get!(Contact, id) |> Repo.preload [:organization, :company]
    company = Repo.get!(CercleApi.Company, reward.company_id) |> Repo.preload [:users]

    query = from p in Organization,
      order_by: [desc: p.inserted_at]
    organizations = Repo.all(query)

    query1 = from reward_status_history in CercleApi.TimelineEvent,
      where: reward_status_history.contact_id == ^reward.id,
      order_by: [desc: reward_status_history.inserted_at]
    reward_status_history = Repo.all(query1) |> Repo.preload [:user]

    changeset = Contact.changeset(reward)
    conn
      |> put_layout("adminlte.html")
      |> render "edit.html", reward: reward, changeset: changeset, company: company, reward_status_history: reward_status_history, organizations: organizations
  end

end
