defmodule CercleApi.Admin.OauthApplicationController do
  use CercleApi.Web, :controller
  alias ExOauth2Provider.OauthApplications
  alias ExOauth2Provider.OauthApplications.OauthApplication
  alias ExOauth2Provider.OauthAccessGrants.OauthAccessGrant
  alias ExOauth2Provider.OauthAccessTokens.OauthAccessToken
  def index(conn, _params) do
    oauth_applications = Repo.all(OauthApplication)
    render(conn, "index.html", oauth_applications: oauth_applications)
  end

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"oauth_application" => oauth_application_params}) do
    case OauthApplications.create_application(CercleApi.AdminUser.system_user, oauth_application_params) do
      {:ok, _oauth_application} ->
        conn
        |> put_flash(:info, "Oauth application created successfully.")
        |> redirect(to: admin_oauth_application_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    oauth_application = ExOauth2Provider.repo.get_by!(OauthApplication, uid: id)
    render(conn, "show.html", oauth_application: oauth_application)
  end

  def edit(conn, %{"id" => id}) do
    oauth_application = ExOauth2Provider.repo.get_by!(OauthApplication, uid: id)
    changeset = OauthApplications.change_application(oauth_application)
    render(conn, "edit.html", oauth_application: oauth_application, changeset: changeset)
  end

  def update(conn, %{"id" => id, "oauth_application" => oauth_application_params}) do
    oauth_application = ExOauth2Provider.repo.get_by!(OauthApplication, uid: id)
    case OauthApplications.update_application(oauth_application, oauth_application_params) do
      {:ok, oauth_application} ->
        conn
        |> put_flash(:info, "Oauth application updated successfully.")
        |> redirect(to: admin_oauth_application_path(conn, :index))
      {:error, changeset} ->
        render(conn, "edit.html", oauth_application: oauth_application, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    app = ExOauth2Provider.repo.get_by!(OauthApplication, uid: id)

    with q <- from(p in OauthAccessGrant, where: p.application_id == ^app.id),
      do: ExOauth2Provider.repo.delete_all(q)

    with q <- from(p in OauthAccessToken, where: p.application_id == ^app.id),
      do: ExOauth2Provider.repo.delete_all(q)

    {:ok, _application} = OauthApplications.delete_application(app)
    conn
    |> put_flash(:info, "Oauth application deleted successfully.")
    |> redirect(to: admin_oauth_application_path(conn, :index))
  end
end
