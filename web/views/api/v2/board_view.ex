defmodule CercleApi.APIV2.BoardView do
  use CercleApi.Web, :view

  def render("index.json", %{boards: boards}) do
    %{data: render_many(boards, CercleApi.APIV2.BoardView, "board.json")}
  end

  def render("show.json", %{board: board}) do
    %{data: render_one(board, CercleApi.APIV2.BoardView, "board.json")}
  end

  def render("board.json", %{board: board}) do
    %{id: board.id,
      name: board.name,
      company_id: board.company_id}
  end
end
