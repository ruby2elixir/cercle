defmodule CercleApi.Settings.CompanyController do
  use CercleApi.Web, :controller
  alias CercleApi.Company

  def edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
    changeset = Company.changeset(company)

    conn
    |> put_layout("adminlte.html")
    |> render "edit.html", company: company, changeset: changeset, settings: true
  end

  def update(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
    company_params = _params["company"]
    changeset = Company.changeset(company, company_params)

    case Repo.update(changeset) do
      {:ok, company} ->
        conn
        |> put_flash(:success, "Company updated successfully.")
        |> redirect(to: "/settings/company")
      {:error, changeset} ->
        render(conn, "edit.html", company: company, changeset: changeset, settings: true)
    end
  end

end
