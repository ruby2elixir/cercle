defmodule CercleApi.RegistrationController do
  use CercleApi.Web, :controller

  alias CercleApi.User
  alias CercleApi.Company
  alias Passport.Session

  def new(conn, _params) do
    changeset = User.changeset(%CercleApi.User{})
    conn
    |> render(:new, changeset: changeset)
  end

  def create(conn, %{"user" => registration_params, "company" => company_params}) do
    changeset = Company.changeset(%Company{}, company_params)
    case Repo.insert(changeset) do
      {:ok, company} ->
        registration_params = %{registration_params | "company_id" => company.id}
        changeset = User.registration_changeset(%User{}, registration_params)
        case Repo.insert(changeset) do
          {:ok, user} ->
            conn
              |> assign(:current_user, user)
              |> put_session(:user_id, user.id)
              |> configure_session(renew: true)
              |> put_flash(:info, "Account created!")
              |> redirect(to: "/opportunity")
          {:error, changeset} ->
            conn
              |> render(:new, changeset: changeset)
        end
      {:error, changeset} ->
        conn
          |> render(:new, changeset: changeset)
    end
  end
end
