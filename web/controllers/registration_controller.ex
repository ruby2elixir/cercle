defmodule CercleApi.RegistrationController do
  use CercleApi.Web, :controller

  alias CercleApi.{ User, Company, Board, BoardColumn }

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
            |> render(:new, changeset: changeset)
        end
      {:error, changeset} ->
        conn
          |> render(:new, changeset: changeset)
    end
  end
end
