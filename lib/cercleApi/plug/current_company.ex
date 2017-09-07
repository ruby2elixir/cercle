defmodule CercleApi.Plug.CurrentCompany do
  @moduledoc false
  import Plug.Conn
  import Ecto
  import Ecto.Query, only: [from: 1, from: 2]
  alias CercleApi.{Company, Repo}

  def init(opts), do: opts

  def call(conn, _opts) do
    user = CercleApi.Plug.current_user(conn)

    if conn.assigns[:override_company_id] do
      company = Company.get_company(user, conn.assigns[:override_company_id])
      if company do
        claims = %{current_company_id: company.id}
        conn
        |> Guardian.Plug.sign_in(user, :access, claims)
        |> assign(:current_company, company)
      else
        conn
        |> Phoenix.Controller.put_flash(:error, "Incorrect company_id")
        |> Phoenix.Controller.redirect(to: "/board")
        |> halt
      end
    else
        with {:ok, claims} <- Guardian.Plug.claims(conn),
             company_id <- Map.get(claims, "current_company_id"),
               company <- Company.get_company(user, company_id),
               false <- is_nil(company) do
          assign(conn, :current_company, company)
        else
          _ ->
            with company <- Company.get_company(user), false <- is_nil(company) do
              claims = %{current_company_id: company.id}
              conn
              |> Guardian.Plug.sign_in(user, :access, claims)
              |> assign(:current_company, company)
            else
              _ -> conn
            end
        end
    end
  end
end
