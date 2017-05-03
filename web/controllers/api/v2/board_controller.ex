defmodule CercleApi.APIV2.BoardController do

  require Logger
  use CercleApi.Web, :controller
  alias CercleApi.Board
  alias CercleApi.BoardColumn
  alias CercleApi.Contact
  alias CercleApi.Company
  alias CercleApi.Organization
  alias CercleApi.User

  plug Guardian.Plug.EnsureAuthenticated
  plug CercleApi.Plugs.CurrentUser

  plug :scrub_params, "board" when action in [:create, :update]

  plug :authorize_resource, model: Board, only: [:update, :delete],
  unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    company_id  = current_user.company_id
    query = from p in Board,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

    boards = query
    |> Repo.all

    render(conn, "index.json", boards: boards)
  end

  def create(conn, %{"board" => board_params}) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get!(Company, user.company_id)

    changeset = company
      |> Ecto.build_assoc(:boards)
      |> Board.changeset(board_params)

    case Repo.insert(changeset) do
      {:ok, board} ->
        steps = ["Step 1", "Step 2", "Step 3", "Step 4", "Step 5"]
        Enum.each [0, 1, 2, 3, 4], fn (index) ->
          boardcol_params = %{:board_id => board.id, :order => index, :name => Enum.at(steps, index)}
          changeset = BoardColumn.changeset(%BoardColumn{}, boardcol_params)
          board_column = CercleApi.Repo.insert!(changeset)
        end

        conn
        |> put_status(:created)
        |> render("show.json", board: board)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "board" => board_params}) do
    board = Repo.get!(Board, id)
    changeset = Board.changeset(board, board_params)
    case Repo.update(changeset) do
      {:ok, board} ->
        render(conn, "show.json", board: board)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
  end

  def archive(conn, %{"board_id" => id}) do
    board = Repo.get!(Board, id)
    changeset = Board.changeset(board, %{archived: true})
    case Repo.update(changeset) do
      {:ok, board} ->
        json conn, %{status: 200}
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

end
