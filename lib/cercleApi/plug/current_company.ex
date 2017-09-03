defmodule CercleApi.Plug.CurrentCompany do
  import Plug.Conn
  import Ecto
  import Ecto.Query, only: [from: 1, from: 2]
  alias CercleApi.Repo

  def init(opts), do: opts

  def call(conn, _opts) do
    user = CercleApi.Plug.current_user(conn)

    with {:ok, claims} <- Guardian.Plug.claims(conn),
         company_id <- Map.get(claims, "current_company_id"),
           company <- get_company(user, company_id),
           false <- is_nil(company) do
      assign(conn, :current_company, company)
    else
      _ ->
        company = get_company(user)
      conn
      |> Guardian.Plug.sign_in(user, :access, %{ current_company_id: company.id })
      |> assign(:current_company, company)
    end
  end

  defp get_company(user, company_id) do
    Repo.one(
      from c in CercleApi.Company,
      join: p in assoc(c, :users),
      where: p.id == ^user.id,
      where: c.id == ^company_id
    )
  end

  defp get_company(user) do
    Repo.one(
      from c in CercleApi.Company,
      join: p in assoc(c, :users),
      where: p.id == ^user.id)
  end
end
