defmodule CercleApi.APIV2.OpportunityController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Opportunity,Contact,Company,Organization,User}

  plug Guardian.Plug.EnsureAuthenticated
  plug CercleApi.Plugs.CurrentUser

  plug :scrub_params, "opportunity" when action in [:create, :update]

  plug :authorize_resource, model: Opportunity, only: [:update, :delete],
  unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def create(conn, %{"opportunity" => opportunity_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    contact = Repo.get!(CercleApi.Contact,
      opportunity_params["main_contact_id"]) |> Repo.preload [:organization]

    board = Repo.get!(CercleApi.Board, opportunity_params["board_id"])
    
    name = board.name

    opportunity_params = %{opportunity_params | "name" => name}
    changeset = current_user
    |> build_assoc(:opportunities)
    |> Opportunity.changeset(opportunity_params)

    case Repo.insert(changeset) do
      {:ok, opportunity} ->
        channel = "contacts:"  <> to_string(contact.id)
        CercleApi.Endpoint.broadcast!(
          channel, "opportunity:created", %{
            "opportunity" => opportunity
          }
        )
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

        channel = "opportunities:"  <> to_string(opportunity.id)
        CercleApi.Endpoint.broadcast!(
          channel, "opportunity:updated", %{
            "opportunity" => opportunity,
            "opportunity_contacts" => opportunity_contacts,
            "board" => board,
            "board_columns" => board.board_columns
          }
        )
        if opportunity.status == 1 do
          CercleApi.Endpoint.broadcast!(
            channel, "opportunity:closed", %{"opportunity" => opportunity }
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
    opportunity = Repo.get!(Opportunity, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(opportunity)

    json conn, %{status: 200}
  end
end
