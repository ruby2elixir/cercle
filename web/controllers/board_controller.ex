defmodule CercleApi.BoardController do
  use CercleApi.Web, :controller

  alias CercleApi.User
  alias CercleApi.Contact
  alias CercleApi.Organization
  alias CercleApi.Opportunity
  alias CercleApi.TimelineEvent
  alias CercleApi.Board
	
  alias CercleApi.Company

	require Logger

  def index(conn, _params) do
    company_id = conn.assigns[:current_user].company_id

    query = from p in Board,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

    boards = Repo.all(query) 

    conn
      |> put_layout("adminlte.html")
      |> render "index.html", boards: boards
  end
	
  def show(conn, %{"id" => id}) do
    
    board = Repo.get!(CercleApi.Board, id)
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

		cards = Repo.all(query_cards)   |> Repo.preload([:user, {:main_contact, activities: (from a in CercleApi.Activity, where: a.is_done == false) }, {:main_contact, timeline_event: from(CercleApi.TimelineEvent, order_by: [desc: :inserted_at])}])



		conn
		  |> put_layout("adminlte.html")
		  |> render "show.html",  company: company, cards: cards
  end

  def new(conn, _params) do
    
    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    conn
      |> put_layout("app2.html")
      |> render "new.html", company: company
  end

  def edit(conn, %{"id" => id}) do
    company_id = conn.assigns[:current_user].company_id
    reward = Repo.get!(Contact, id) |> Repo.preload [:organization, :company]
    company = Repo.get!(CercleApi.Company, reward.company_id) |> Repo.preload [:users]

    query = from p in Organization,
      order_by: [desc: p.inserted_at]
    organizations = Repo.all(query)

    query = from reward_status_history in CercleApi.TimelineEvent,
      where: reward_status_history.contact_id == ^reward.id,
      order_by: [desc: reward_status_history.inserted_at]
    reward_status_history = Repo.all(query) |> Repo.preload [:user]

    changeset = Contact.changeset(reward)
		conn
		  |> put_layout("adminlte.html")
		  |> render "edit.html", reward: reward, changeset: changeset, company: company, reward_status_history: reward_status_history, organizations: organizations
  end

end
