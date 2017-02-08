defmodule CercleApi.Plugs.RequireAuth do
  import Plug.Conn
  alias Checklist.Router.Helpers

  def init(default), do: default

  def call(conn, _params) do
    case conn.assigns.current_user do
      nil ->
        conn
        |> Plug.Conn.put_session(:redirect_url, conn.request_path)
        |> Phoenix.Controller.put_flash(:info, "Please log in or register to continue.")
        |> Phoenix.Controller.redirect(to: "/login")
      _ ->
        conn
    end
  end
end