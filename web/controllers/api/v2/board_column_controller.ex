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
  end

end
