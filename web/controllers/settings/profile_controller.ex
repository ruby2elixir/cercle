defmodule CercleApi.Settings.ProfileController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company, Tag}

  def edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    changeset = User.changeset(user)
    company = current_company(conn)

    conn
    |> put_layout("adminlte.html")
    |> render("edit.html", changeset: changeset, company: company, user: user)
  end

  def update(conn, %{"user" => user_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = User.update_changeset(user, user_params)
    company = current_company(conn)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: front_edit_profile_path(conn, :edit, company))
      {:error, changeset} ->
        conn
        |> put_layout("adminlte.html")
        |> render("edit.html", changeset: changeset, company: company, user: user)
    end
  end
end
