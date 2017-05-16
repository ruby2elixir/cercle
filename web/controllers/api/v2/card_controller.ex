defmodule CercleApi.APIV2.CardController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Card, Contact, Company, Organization, User, Board, CardService}

  plug Guardian.Plug.EnsureAuthenticated
  plug CercleApi.Plugs.CurrentUser

  plug :scrub_params, "card" when action in [:create, :update]

  plug :authorize_resource, model: Card, only: [:update, :delete, :show],
  unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def show(conn, %{"id" => id}) do
    card = Card
    |> Card.preload_data
    |> Repo.get(id)

    card_contacts = Card.contacts(card)

    board = Board
    |> Repo.get!(card.board_id)
    |> Repo.preload([:board_columns])

    render(conn, "full_card.json",
      card: card,
      card_contacts: card_contacts,
      board: board,
      attachments: card.attachments
    )
  end

  def create(conn, %{"card" => card_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    company = Repo.get!(Company, current_user.company_id)
    contact = CercleApi.Contact
    |> Repo.get!(card_params["main_contact_id"])
    |> Repo.preload([:organization])

    board = Repo.get!(CercleApi.Board, card_params["board_id"])

    changeset = company
    |> build_assoc(:cards)
    |> Card.changeset(card_params)
    |> Ecto.Changeset.put_change(:contact_ids, [contact.id])

    case Repo.insert(changeset) do
      {:ok, card} ->
        channel = "contacts:"  <> to_string(contact.id)
        CercleApi.Endpoint.broadcast!(
          channel, "card:created", %{
            "card" => card
          }
        )
        CardService.insert(card)
        conn
        |> put_status(:created)
        |> render("show.json", card: card)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "card" => card_params}) do
    card = Repo.get!(Card, id)
    changeset = Card.changeset(card, card_params)

    case Repo.update(changeset) do
      {:ok, card} ->
        card_contacts = CercleApi.Card.contacts(card)
        board = CercleApi.Board
        |> Repo.get!(card.board_id)
        |> Repo.preload(:board_columns)

        channel = "cards:"  <> to_string(card.id)
        CercleApi.Endpoint.broadcast!(
          channel, "card:updated", %{
            "card" => card,
            "card_contacts" => card_contacts,
            "board" => board,
            "board_columns" => board.board_columns
          }
        )
        if card.status == 1 do
          CercleApi.Endpoint.broadcast!(
            channel, "card:closed", %{"card" => card}
          )
        end
        CardService.update(card)
        render(conn, "show.json", card: card)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    card = Repo.get!(Card, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(card)
    CardService.delete(card)

    json conn, %{status: 200}
  end
end
