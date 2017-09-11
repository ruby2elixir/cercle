defmodule CercleApi.Plug.CurrentCompany do
  @moduledoc false
  import Plug.Conn
  import Ecto
  import Ecto.Query, only: [from: 1, from: 2]
  alias CercleApi.{Company, Repo}

  def init(opts), do: opts

  def call(conn, _opts) do
    user = CercleApi.Plug.current_user(conn)
    if user do
      company = Company.get_company(user, conn.params["company_id"])
      assign(conn, :current_company, company)
    else
      conn
    end
  end
end
