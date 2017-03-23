defmodule CercleApi.APIV2.BoardColumnController do

  require Logger
  use CercleApi.Web, :controller
  alias CercleApi.Board
  alias CercleApi.BoardColumn
  alias CercleApi.Contact
  alias CercleApi.Company
  alias CercleApi.Organization
  alias CercleApi.User

  plug Guardian.Plug.EnsureAuthenticated


  def create(conn, %{"board_column" => board_column_params}) do
    board = Repo.get(Board, board_column_params["board_id"]) |> Repo.preload(:board_columns)
    boardcol_params = Map.put(board_column_params, "order", Enum.count(board.board_columns) + 1)
    changeset = BoardColumn.changeset(%BoardColumn{}, boardcol_params)
    case Repo.insert(changeset) do
      {:ok, board_column} ->
        render(conn, "show.json", board_column: board_column)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "board_column" => board_column_params}) do
    board = Repo.get!(BoardColumn, id)
    changeset = BoardColumn.changeset(board, board_column_params)

    case Repo.update(changeset) do
      {:ok, board_column} ->
        render(conn, "show.json", board_column: board_column)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    board_column = Repo.get!(BoardColumn, id)
    Repo.delete!(board_column)
    send_resp(conn, :no_content, "")
  end

end
