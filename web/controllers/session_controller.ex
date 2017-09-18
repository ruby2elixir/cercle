defmodule CercleApi.SessionController do
  use CercleApi.Web, :controller
  alias CercleApi.{User, UserCompany, Company}

  def new(conn, _) do
    conn
    |> render(:new)
  end

  def create(conn, %{"login" => login, "password" => pass, "time_zone" => time_zone}) do

    case CercleApi.Session.authenticate(login, pass, time_zone) do
      {:ok, user} ->
        invite_values = get_session(conn, :invite_values)
        if invite_values do
          delete_session(conn, :invite_values)
          case Cipher.parse(invite_values) do
            {:ok,
             %{"company_id" => company_id, "email" => email}
            } when email == login ->
              company = Repo.get_by!(Company, id: company_id)
              Company.add_user_to_company(user, company)
            _ ->
              company = current_company(conn, user)
          end
        else
          company = Company.get_company(user) || default_company(user)
        end
        path = get_session(conn, :redirect_url) || board_path(conn, :index, company)

        conn
        |> put_flash(:info, "Welcome back!")
        |> Guardian.Plug.sign_in(user)
        |> redirect(to:  path)

      :error ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render(:new)
    end
  end

  def delete(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: session_path(conn, :new))
  end

  defp default_company(user) do
    company_changeset = Company.changeset(%Company{}, %{title: "My company"})
    {:ok, company} = Repo.insert(company_changeset)
    Company.add_user_to_company(user, company)

    company
  end
end
