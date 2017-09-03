defmodule CercleApi.Controllers.Helpers do
  alias CercleApi.Repo
  import Plug.Conn
  import Phoenix.Controller

  def current_company(conn, _user) do
    conn.assigns[:current_company]
  end
end
