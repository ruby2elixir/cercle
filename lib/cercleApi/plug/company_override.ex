defmodule CercleApi.Plug.CompanyOverride do
  import Plug.Conn
  alias Plug.Router.Utils
  def init(opts), do: opts

  def call(conn, _opts) do
    regex = ~r/^\/company\/(?<company_id>\d+)\/(?<path>.+)/
    captures = Regex.named_captures(regex, conn.request_path)
    override_path(conn, captures)
  end

  def override_path(conn, %{"company_id" => company_id, "path" => path}) do
    new_conn = conn
    |> assign(:override_company_id, company_id)
    %{new_conn | request_path: "/#{path}", path_info: Utils.split(path)}
  end

  def override_path(conn, _), do: conn
end
