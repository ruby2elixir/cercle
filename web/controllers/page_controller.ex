defmodule CercleApi.PageController do
  use CercleApi.Web, :controller

  def index(conn, _params) do
    if (conn.assigns[:current_user] && is_integer(conn.assigns[:current_user].company_id) ) do
      conn
        |> redirect(to: "/activity")
        |> halt
    else
      conn
        |> put_layout("app.html")
        |> render("index.html")
    end
  end	

end
