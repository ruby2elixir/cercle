defmodule CercleApi.RegistrationController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company, Board, BoardColumn}

  def new(conn, _params) do
    if _params["email"] do email = _params["email"] end
    if _params["company_name"] do company_name = _params["company_name"] end
    if _params["company_id"] do company_id = _params["company_id"] end

    changeset = User.changeset(%CercleApi.User{})
    conn
    |> render(:new, changeset: changeset, email: email, company_id: company_id, company_name: company_name)
  end

  def create(conn, %{"user" => registration_params, "company" => company_params}) do
    changeset = Company.changeset(%Company{}, company_params)
    if changeset.valid? do
      company = Repo.get_by(Company, id: registration_params["company_id"]) || Repo.insert(changeset)
      registration_params = %{registration_params | "company_id" => company.id}
      changeset = User.registration_changeset(%User{}, registration_params)
      case Repo.insert(changeset) do
        {:ok, user} ->

          changeset = Board.changeset(%Board{}, %{name: "Deals", company_id: company.id})
          board = Repo.insert!(changeset)

          steps = ["Lead in", "Contact Made", "Needs Defined", "Proposal Made", "Negotiation Started"]
          Enum.each [0,1,2,3,4], fn (index) ->
            boardcol_params = %{:board_id => board.id, :order => index, :name => Enum.at(steps, index)}
            changeset = BoardColumn.changeset(%BoardColumn{}, boardcol_params)
            board_column = CercleApi.Repo.insert!(changeset)
          end

          conn
          |> Guardian.Plug.sign_in(user)
          |> configure_session(renew: true)
          |> put_flash(:info, "Account created!")
          |> redirect(to: "/board")
        {:error, changeset} ->
          conn
          |> render(:new, changeset: changeset, company_id: registration_params["company_id"], company_name: company_params["title"], email: registration_params["login"])
      end
    else
      conn
        |> render(:new, changeset: changeset, company_id: registration_params["company_id"], company_name: company_params["title"], email: registration_params["login"])
    end
  end
end
