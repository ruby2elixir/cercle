defmodule CercleApi.APIV2.BoardColumnController do

  require Logger
  use CercleApi.Web, :controller
  alias CercleApi.{Board, BoardColumn, Contact, Company, Organization, User}
  alias CercleApi.Card

  plug CercleApi.Plug.EnsureAuthenticated
  plug CercleApi.Plug.CurrentUser
  plug :scrub_params, "board_column" when action in [:create, :update]

  plug :authorize_resource, model: BoardColumn, only: [:update, :delete],
  unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, params) do
    current_user = CercleApi.Plug.current_user(conn)
    company = current_company(conn)

    if String.strip(params["board_id"]) != "" do
      board = Repo.get(Board, params["board_id"])
      board_id = board.id
      query = from p in BoardColumn,
        where: p.board_id == ^board_id,
        order_by: [desc: p.updated_at]

      board_columns = query
      |> Repo.all

      render(conn, "index.json", board_columns: board_columns)
    else
      json conn, %{"data": []}
    end
  end

  def create(conn, %{"board_column" => board_column_params}) do
    user = CercleApi.Plug.current_user(conn)
    company = current_company(conn)
    board = Repo.get(Board, board_column_params["board_id"])
    if board do
      if board.company_id == company.id do
        board = Repo.get(Board, board_column_params["board_id"]) |> Repo.preload(:board_columns)
        boardcol_params = Map.put(board_column_params, "order", Enum.count(board.board_columns))
        changeset = BoardColumn.changeset(%BoardColumn{}, boardcol_params)
        case Repo.insert(changeset) do
          {:ok, board_column} ->
            Board
            |> Repo.get(board_column.board_id)
            |> Repo.preload([board_columns: Board.preload_query])
            |> CercleApi.BoardNotificationService.update_notification
            render(conn, "show.json", board_column: board_column)
          {:error, changeset} ->
            conn
            |> put_status(:unprocessable_entity)
            |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
        end
      else
        json conn, %{status: 403, error: "You are not authorized for this action!"}
      end
    else
      json conn, %{status: 404, error: "Resource not found!"}
    end
  end

  def update(conn, %{"id" => id, "board_column" => board_column_params}) do
    board_column = Repo.get!(BoardColumn, id)
    changeset = BoardColumn.changeset(board_column, board_column_params)

    case Repo.update(changeset) do
      {:ok, board_column} ->
        Board
        |> Repo.get(board_column.board_id)
        |> Repo.preload([board_columns: Board.preload_query])
        |> CercleApi.BoardNotificationService.update_notification

        render(conn, "show.json", board_column: board_column)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    board_column = Repo.get!(BoardColumn, id)
    column_query = from(p in BoardColumn,
      left_join: c in assoc(p, :cards),
      select: {p, count(c.id)}, group_by: p.id,
      where: p.id == ^id)
    case Repo.one(column_query) do
      {board_column, cards_count} when cards_count == 0 ->
        board_id = board_column.board_id
        board_order = board_column.order
        # reorder columns with greater order
        from(c in BoardColumn,
          where: c.board_id == ^board_id,
          where: c.order > ^board_order,
          update: [set: [order: fragment("? - 1", c.order)]])
          |> Repo.update_all([])

        Repo.delete!(board_column)

        Board
        |> Repo.get(board_column.board_id)
        |> Repo.preload([board_columns: Board.preload_query])
        |> CercleApi.BoardNotificationService.update_notification

        json conn, %{status: 200}

      _ ->
        conn
        |> put_status(:unprocessable_entity)
        |> json %{reason: "column don't be removed while the column has cards"}
    end

  end

  def reorder_cards(conn, %{"board_column_id" => id, "card_ids" => card_ids}) do
    board_column = Repo.get!(BoardColumn, id)

    card_ids
    |> Enum.with_index
    |> Enum.each(fn({x, i}) ->
      card = Repo.get_by(Card, id: x)
      changeset = Card.changeset(card, %{position: i})
      Repo.update(changeset)
    end)

    Board
    |> Repo.get(board_column.board_id)
    |> Repo.preload([board_columns: Board.preload_query])
    |> CercleApi.BoardNotificationService.update_notification
    render(conn, "show.json", board_column: board_column)
  end
end
