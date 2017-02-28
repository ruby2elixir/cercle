defmodule CercleApi.GuardianAlreadyAuthenticatedHandler do
  import Plug.Conn
  import CercleApi.Router.Helpers

  def already_authenticated(conn, _params) do
    conn
    |> Phoenix.Controller.redirect(to: board_path(conn, :index))
  end
end
