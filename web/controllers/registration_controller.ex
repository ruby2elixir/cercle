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

        if company_params["id"] != "" do
          company = Repo.get_by(Company, id: company_params["id"])
        else
          {:ok, company} = Repo.insert(company_changeset)
        end

        changeset = %User{}
        |> User.registration_changeset(registration_params)

        case Repo.insert(changeset) do
          {:ok, user} ->
            join_to_company(user, company)
            changeset = Board.changeset(%Board{}, %{name: "Deals", company_id: company.id})
            board = Repo.insert!(changeset)
            steps = ["Lead in", "Contact Made", "Needs Defined", "Proposal Made", "Negotiation Started"]
            Enum.each [0, 1, 2, 3, 4], fn (index) ->
              boardcol_params = %{:board_id => board.id, :order => index, :name => Enum.at(steps, index)}
              changeset = BoardColumn.changeset(%BoardColumn{}, boardcol_params)
              CercleApi.Repo.insert!(changeset)
            end

            conn
            |> Guardian.Plug.sign_in(user)
            |> configure_session(renew: true)
            |> put_flash(:info, "Account created!")
            |> redirect(to: "/board")
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
    case Cipher.parse register_values do
      {:ok, decoded_values} ->
        if decoded_values["company_id"] do company_id = decoded_values["company_id"] end
        if decoded_values["email"] do email = decoded_values["email"] end
        company = Repo.get(Company, company_id)
        current_user = CercleApi.Plug.current_user(conn)
        if current_user do
          if current_user.login == email do
            join_to_company(current_user, company)
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
          |> render(:new, changeset: changeset, company_id: company.id, company_title: company.title, user_login: email)
        end
      {:error, _error} ->
        conn
        |> put_flash(:error, "Invalid link!")
        |> redirect(to: "/")
    end
  end

  defp join_to_company(user, company) do
    %UserCompany{}
    |> UserCompany.changeset(%{user_id: user.id, company_id: company.id})
    |> Repo.insert
  end
end
