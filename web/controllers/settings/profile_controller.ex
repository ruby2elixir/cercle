defmodule CercleApi.Settings.ProfileController do
  use CercleApi.Web, :controller

  alias CercleApi.User

  def edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    changeset = User.changeset(user)
    company = current_company(conn)

    conn
    |> put_layout("adminlte.html")
    |> render("edit.html", changeset: changeset, company: company, user: user)
  end

end
