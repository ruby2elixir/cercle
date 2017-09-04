defmodule CercleApi.Controllers.Helpers do
  @moduledoc """
  Controller helpers
  """
  alias CercleApi.Repo
  import Plug.Conn
  import Phoenix.Controller

  def current_company(conn, _user) do
    conn.assigns[:current_company]
  end

  def current_company(conn) do
    conn.assigns[:current_company]
  end
end
