defmodule CercleApi.APIV2.OpportunityAttachmentController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Opportunity, OpportunityAttachment, User}

  plug Guardian.Plug.EnsureAuthenticated
  plug CercleApi.Plugs.CurrentUser

  plug :authorize_resource, model: Opportunity, only: [:index, :create, :delete],
  unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, %{"opportunity_id" => opportunity_id}) do
    attachments = Opportunity
    |> Repo.get(opportunity_id)
    |> Repo.preload([:attachments])

    render(conn, "index.json", attachments: attachments)
  end

  def create(conn, %{"opportunity_id" => opportunity_id}) do
    opportunity = Repo.get!(Opportunity, opportunity_id)

  end

  def delete(conn, %{"opportunity_id" => opportunity_id}) do
    opportunity = Repo.get!(Opportunity, opportunity_id)
  end
end
