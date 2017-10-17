defmodule CercleApi.LayoutView do
  use CercleApi.Web, :view

  def wrapper_css_class(conn) do
    cond do
      conn.assigns[:contact] ->
        "contact"
      conn.assigns[:board] ->
        "board"
      true ->
        ""
    end
  end

  def show_board_menu?(conn) do
    if conn.assigns[:show_board] do
      true
    else
      false
    end
  end
end
