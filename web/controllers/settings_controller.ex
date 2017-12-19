defmodule CercleApi.SettingsController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company, Tag, UserCompany}

  def team_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.preload(current_company(conn), [:users])

    conn
    |> put_layout("adminlte.html")
    |> render "team_edit.html", company: company
  end

  def fields_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
    changeset = Company.changeset(company)

    conn
    |> put_layout("adminlte.html")
    |> render "fields_edit.html", company: company, changeset: changeset, settings: true
  end

  def tags_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
    query = from t in Tag,
      where: t.company_id == ^company.id,
      order_by: [desc: t.inserted_at]
    tags = Repo.all(query)
    conn
    |> put_layout("adminlte.html")
    |> render "tags_edit.html", tags: tags
  end

  def api_key(conn, _params) do
    conn
    |> put_layout("adminlte.html")
    |> render "api_key.html"
  end

  def webhooks(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)

    conn
    |> put_layout("adminlte.html")
    |> render("webhooks.html", company: company, user: user)
  end
end
