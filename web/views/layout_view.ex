defmodule CercleApi.LayoutView do
  use CercleApi.Web, :view
  def show_board_menu?(conn) do
    if conn.assigns[:show_board] do
      true
    else
      false
    end
  end
end
