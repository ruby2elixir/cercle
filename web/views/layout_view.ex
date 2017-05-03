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

  def show_menu?(conn) do
    if conn.assigns[:board] do
      true
    else
      false
    end
  end

  def show_recent_activities?(conn) do
    conn.assigns[:board]
  end

  def archive_board?(conn) do
    conn.assigns[:board] && !conn.assigns[:board].archived
  end

  def unarchive_board?(conn) do
    conn.assigns[:board] && conn.assigns[:board].archived
  end
end
