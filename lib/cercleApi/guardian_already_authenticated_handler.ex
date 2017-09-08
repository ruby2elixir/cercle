defmodule CercleApi.GuardianAlreadyAuthenticatedHandler do
  import Plug.Conn
  import CercleApi.Router.Helpers
  alias CercleApi.{Company, Repo}

  def already_authenticated(conn, _params) do
    company = conn
    |> CercleApi.Plug.current_user
    |> Company.get_company
    conn
    |> Phoenix.Controller.redirect(to: "/company/#{company.id}/board")
  end
end
