defmodule CercleApi.BoardController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Contact, Organization, Card, TimelineEvent, Board, Company}

  require Logger

  plug :authorize_resource, model: Board, only: [:show],
  unauthorized_handler: {CercleApi.Helpers, :handle_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_not_found}

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)

    query = from p in Board,
      where: p.company_id == ^company.id,
      order_by: [desc: p.updated_at]

    boards = Repo.all(query)

    conn
      |> put_layout("adminlte.html")
      |> render "index.html", boards: boards
  end

  def new(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = conn
    |> current_company
    |> Repo.preload([:users])

    changeset = Board.changeset(%Board{}, %{name: "", company_id: company.id, archived: false, type_of_card: 0})

    conn
      |> put_layout("adminlte.html")
      |> render "new.html", company: company, changeset: changeset
  end

  def create(conn, %{"board" => board_params}) do
    user = Guardian.Plug.current_resource(conn)
    company = conn
    |> current_company
    |> Repo.preload([:users])

    changeset = company
      |> Ecto.build_assoc(:boards)
      |> Board.changeset(board_params)

    case Repo.insert(changeset) do
      {:ok, board} ->
        conn
        |> put_flash(:info, "Board created successfully.")
        |> redirect(to: front_board_path(conn, :show, company.id, board.id))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    board = CercleApi.Board
    |> Repo.get!(id)
    |> Repo.preload(board_columns: from(CercleApi.BoardColumn, order_by: [asc: :order]))
    board_id = board.id
    company = conn
    |> current_company
    |> Repo.preload([:users])

    conn
      |> put_layout("adminlte.html")
      |> render "show.html",  company: company, board: board, no_container: true, show_board: true
  end

  def edit(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    
    company = conn
    |> current_company
    |> Repo.preload([:users])

    board = Repo.get!(CercleApi.Board, id)

    changeset = Board.changeset(board, %{})

    conn
      |> put_layout("adminlte.html")
      |> render "edit.html", board: board, changeset: changeset
  end

  def update(conn, %{"id" => id, "board" => board_params}) do
    user = Guardian.Plug.current_resource(conn)
    
    company = conn
    |> current_company
    |> Repo.preload([:users])

    board = Repo.get!(Board, id)
    changeset = Board.changeset(board, board_params)

    case Repo.update(changeset) do
      {:ok, board} ->
        board = board
        |> Repo.preload([board_columns: Board.preload_query])
        CercleApi.BoardNotificationService.update_notification(board)
        conn
        |> put_flash(:info, "Board updated successfully.")
        |> redirect(to: front_board_path(conn, :show, company.id, board.id))
      {:error, changeset} ->
        render(conn, "edit.html", board: board, changeset: changeset)
    end
  end

end
