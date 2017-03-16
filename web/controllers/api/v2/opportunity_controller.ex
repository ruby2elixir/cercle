defmodule CercleApi.APIV2.OpportunityController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.Opportunity
  alias CercleApi.Contact
  alias CercleApi.Company
  alias CercleApi.Organization
  alias CercleApi.User

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "opportunity" when action in [:create, :update]

  def create(conn, %{"opportunity" => opportunity_params}) do
    contact = Repo.get!(CercleApi.Contact, opportunity_params["main_contact_id"]) |> Repo.preload [:organization]

    board = Repo.get!(CercleApi.Board, opportunity_params["board_id"])

    name = ""
    if contact.organization do
      name = contact.organization.name <> " / " <> board.name
    else
      name = contact.name <> " / " <> board.name
    end

    opportunity_params = %{ opportunity_params | "name" => name }
    changeset = Opportunity.changeset(%Opportunity{}, opportunity_params)
    case Repo.insert(changeset) do
      {:ok, opportunity} ->
        conn
        |> put_status(:created)
        |> render("show.json", opportunity: opportunity)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "opportunity" => opportunity_params}) do
    opportunity = Repo.get!(Opportunity, id)
    changeset = Opportunity.changeset(opportunity, opportunity_params)

    case Repo.update(changeset) do
      {:ok, opportunity} ->
        opportunity_contacts = CercleApi.Opportunity.contacts(opportunity)
        board = Repo.get!(CercleApi.Board, opportunity.board_id)
        |> Repo.preload(:board_columns)

        Enum.each opportunity.contact_ids, fn (contact_id) ->
          channel = "contacts:"  <> to_string(contact_id)
          CercleApi.Endpoint.broadcast!(
            channel, "opportunity:updated", %{
              "opportunity" => opportunity,
              "opportunity_contacts" => opportunity_contacts,
              "board" => board,
              "board_columns" => board.board_columns
            }
          )
        end
        render(conn, "show.json", opportunity: opportunity)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    contact = Repo.get!(Contact, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(contact)

    send_resp(conn, :no_content, "")
  end
end
