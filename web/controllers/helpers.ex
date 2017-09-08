defmodule CercleApi.Controllers.Helpers do
  @moduledoc """
  Controller helpers
  """
  alias CercleApi.{Repo, Company}
  import Plug.Conn
  import Phoenix.Controller

  def current_company(conn, user) do
    conn.assigns[:current_company] || Company.get_company(user)
  end

  def current_company(conn) do
    conn.assigns[:current_company]
  end
end
