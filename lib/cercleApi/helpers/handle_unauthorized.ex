defmodule CercleApi.Helpers do
  import Plug.Conn
  import CercleApi.Router.Helpers

  def handle_unauthorized(conn) do
    conn
    |> Phoenix.Controller.put_flash(:error, "You are not authorized for this action!")
    |> Phoenix.Controller.redirect(to: "/")
    |> halt
  end

  def handle_not_found(conn) do
    conn
    |> Phoenix.Controller.put_flash(:error, "Resource not found")
    |> Phoenix.Controller.redirect(to: "/")
    |> halt
  end

  def handle_json_unauthorized(conn) do
    conn
    |> respond(403, "You are not authorized for this action!")
    |> halt
    end

  def handle_json_not_found(conn) do
    conn
    |> respond(404, "Resource not found")
    |> halt
  end

  defp respond(conn, status, msg) do
    try do
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Poison.encode!(%{error: msg}))
    rescue ArgumentError ->
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(status, Poison.encode!(%{error: msg}))
    end
  end

end
