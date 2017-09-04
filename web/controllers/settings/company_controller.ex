defmodule CercleApi.Settings.CompanyController do
  use CercleApi.Web, :controller
  alias CercleApi.Company

  def index(conn, _params) do
    user = conn
    |> Guardian.Plug.current_resource
    |> Repo.preload([:companies])

    conn
    |> put_layout("adminlte.html")
    |> render "index.html", companies: user.companies, user: user
  end

  def edit(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.one(
      from c in CercleApi.Company,
      join: p in assoc(c, :users),
      where: p.id == ^user.id,
      where: c.id == ^id
    )
    changeset = Company.changeset(company)

    conn
    |> put_layout("adminlte.html")
    |> render "edit.html", company: company, changeset: changeset, settings: true
  end

  def update(conn,  %{"id" => id, "company" => company_params}) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.one(
      from c in CercleApi.Company,
      join: p in assoc(c, :users),
      where: p.id == ^user.id,
      where: c.id == ^id
    )
    changeset = Company.changeset(company, company_params)

    case Repo.update(changeset) do
      {:ok, company} ->
        conn
        |> put_flash(:success, "Company updated successfully.")
        |> redirect(to: "/settings/companies")
      {:error, changeset} ->
        render(conn, "edit.html", company: company, changeset: changeset, settings: true)
    end
  end

end
