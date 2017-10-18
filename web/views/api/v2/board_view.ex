defmodule CercleApi.APIV2.BoardView do
  use CercleApi.Web, :view

  def render("index.json", %{boards: boards}) do
    %{data: render_many(boards, CercleApi.APIV2.BoardView, "board.json")}
  end

  def render("show.json", %{board: board}) do
    %{data: render_one(board, CercleApi.APIV2.BoardView, "board.json")}
  end

  def render("full_show.json", %{board: board}) do
    %{data: board_json(board)}
  end

  def render("board.json", %{board: board}) do
    %{id: board.id,
      name: board.name,
      type_of_card: board.type_of_card,
      company_id: board.company_id,
      board_columns: render_many(
        board.board_columns,
        CercleApi.APIV2.BoardColumnView,
        "board_column.json")}
  end

  def board_json(board) do
    %{id: board.id,
      name: board.name,
      type_of_card: board.type_of_card,
      company_id: board.company_id,
      board_columns: render_many(
        board.board_columns,
        CercleApi.APIV2.BoardColumnView,
        "board_column_with_cards.json")
    }
  end
end
