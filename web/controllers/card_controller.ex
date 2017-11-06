defmodule CercleApi.CardController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Card, Board, Company}

  require Logger

  plug :authorize_resource, model: Card, only: [:show],
  unauthorized_handler: {CercleApi.Helpers, :handle_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_not_found}

  def show(conn, %{"board_id" => board_id, "id" => id}) do
    current_user = Guardian.Plug.current_resource(conn)
    company = current_company(conn, current_user)
    card = Card
    |> Repo.get_by(id: id, board_id: board_id)

    conn
      |> put_layout("adminlte.html")
      |> render "show.html",  company: company, card: card, no_container: true
  end

end
