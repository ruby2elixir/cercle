defmodule CercleApi.CompanyController do
  use CercleApi.Web, :controller
  alias CercleApi.Company

  def set(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    with company <- get_company(user, id), false <- is_nil(company) do
      claims = %{current_company_id: company.id}
      conn
      |> Guardian.Plug.sign_in(user, :access, claims)
      |> redirect(to:  "/board")
    else
      _ ->
        redirect(conn, to:  "/board")
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

end
