defmodule CercleApi.APIV2.OpportunityAttachmentController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Opportunity, OpportunityAttachment, User}

  plug Guardian.Plug.EnsureAuthenticated
  plug CercleApi.Plugs.CurrentUser

  plug :authorize_resource, model: OpportunityAttachment, only: [:create, :delete],
  unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, %{"opportunity_id" => opportunity_id}) do
    opportunity = Opportunity
    |> Repo.get(opportunity_id)
    |> Repo.preload([:attachments])

    render(conn, "index.json", attachments: opportunity.attachments)
  end

  def create(conn, %{"opportunity_id" => opportunity_id, "attachment" => attachment}) do
    # user = Guardian.Plug.current_resource(conn)
    # opportunity = Repo.get!(Opportunity, opportunity_id)
    # changeset = OpportunityAttachment.changeset(%OpportunityAttachment{}, %{"attachment" => attachment})
    # case Repo.insert(changeset) do
    #   {:ok, opportunity_attachment} ->
    #     render(conn, "show.json", opportunity_attachment: opportunity_attachment)
    #   {:error, changeset} ->
    #     conn
    #     |> put_status(:unprocessable_entity)
    #     |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    # end
  end

  def delete(conn, %{"opportunity_id" => opportunity_id}) do
    opportunity = Repo.get!(Opportunity, opportunity_id)
  end
end
