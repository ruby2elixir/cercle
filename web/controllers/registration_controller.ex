defmodule CercleApi.RegistrationController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company, Board, BoardColumn, UserCompany}

  def new(conn, _params) do
    changeset = User.changeset(%CercleApi.User{})
    conn
    |> render(:new, changeset: changeset)
  end

  def create(conn, %{"user" => registration_params, "company" => company_params}) do
    company_changeset = Company.changeset(%Company{}, company_params)
    if company_changeset.valid? do
      user_changeset = User.registration_changeset(%User{}, registration_params)
      if user_changeset.valid? do
        invite_values = get_session(conn, :invite_values)
        if invite_values do
          delete_session(conn, :invite_values)
          user_login = registration_params["login"]
          case Cipher.parse(invite_values) do
            {:ok,
             %{"company_id" => company_id, "email" => email}
            } when email == user_login ->
              company = Repo.get_by(Company, id: company_id)
          end
        end
        if !company do
          {:ok, company} = Repo.insert(company_changeset)
        end
        changeset = %User{}
        |> User.registration_changeset(registration_params)

        case Repo.insert(changeset) do
          {:ok, user} ->
            Company.add_user_to_company(user, company)
            changeset = Board.changeset(%Board{}, %{name: "Deals", company_id: company.id})
            board = Repo.insert!(changeset)
            steps = ["New Lead", "Interested in", "Proposition sent"]
            Enum.each [0, 1, 2], fn (index) ->
              boardcol_params = %{:board_id => board.id, :order => index, :name => Enum.at(steps, index)}
              changeset = BoardColumn.changeset(%BoardColumn{}, boardcol_params)
              CercleApi.Repo.insert!(changeset)
            end

            conn
            |> Guardian.Plug.sign_in(user)
            |> configure_session(renew: true)
            |> put_flash(:info, "Account created!")
            |> redirect(to: board_path(conn, :index, company))
          {:error, changeset} ->
            conn
            |> render(:new, changeset: changeset,
            user_name: registration_params["user_name"],
            company_id: company.id,
            company_title: company.title,
            user_login: registration_params["login"])
        end
      else
        conn
        |> render(:new, changeset: %{user_changeset | action: :insert},
        user_name: registration_params["user_name"],
        company_id: company_params["id"],
        company_title: company_params["title"],
        user_login: registration_params["login"])
      end
    else
      conn
      |> render(:new, changeset: %{company_changeset | action: :insert},
      user_name: registration_params["user_name"],
      company_id: company_params["id"],
      company_title: company_params["title"],
      user_login: registration_params["login"])
    end
  end

  def accept_team_invitation(conn, params) do
    register_values = params["register_values"]
    case Cipher.parse(register_values) do
      {:ok, %{"company_id" => company_id, "email" => email}} ->
        company = Repo.get(Company, company_id)
        current_user = CercleApi.Plug.current_user(conn)

        if current_user do
          if current_user.login == email do
            Company.add_user_to_company(current_user, company)
            conn
            |> put_flash(:info, "Successfully!")
            |> redirect(to: "/")
          else
            conn
            |> put_flash(:error, "Invalid link!")
            |> redirect(to: "/")
          end
        else
          changeset = User.changeset(%CercleApi.User{})
          conn
          |> put_session(:invite_values, params["register_values"])
          |> render(:new, changeset: changeset,  company_title: company.title, user_login: email)
        end

      {:error, _error} ->
        conn
        |> put_flash(:error, "Invalid link!")
        |> redirect(to: "/")
    end
  end
end
