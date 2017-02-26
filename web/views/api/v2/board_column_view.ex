defmodule CercleApi.APIV2.BoardColumnView do
  use CercleApi.Web, :view

  def render("index.json", %{board_columns: board_columns}) do
    %{data: render_many(board_columns, CercleApi.APIV2.BoardColumnView, "board.json")}
  end

  def render("show.json", %{board_column: board_column}) do
    %{data: render_one(board_column, CercleApi.APIV2.BoardColumnView, "board.json")}
  end

  def render("board.json", %{board_column: board_column}) do
    %{id: board_column.id}
  end
end
