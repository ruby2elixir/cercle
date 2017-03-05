defmodule CercleApi.CurrentUserController do
  use CercleApi.Web, :controller
  alias CercleApi.User

  plug Guardian.Plug.EnsureAuthenticated, handler: __MODULE__

  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    token = Guardian.Plug.current_token(conn)
    conn
    |> put_status(:ok)
    |> render("show.json", token: token, user: user)
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(:forbidden)
    |> render("forbidden.json", error: "Not Authenticated")
  end
end
