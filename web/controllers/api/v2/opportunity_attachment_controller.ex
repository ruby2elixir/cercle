defmodule CercleApi.APIV2.OpportunityAttachmentController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.{Opportunity, OpportunityAttachment, OpportunityAttachmentFile, User}

  plug Guardian.Plug.EnsureAuthenticated
  plug CercleApi.Plugs.CurrentUser

  # plug :authorize_resource, model: OpportunityAttachment, only: [:create, :delete],
  #   unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  #   not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, %{"opportunity_id" => opportunity_id}) do
    opportunity = Opportunity
    |> Repo.get(opportunity_id)
    |> Repo.preload([:attachments])

    render(conn, "index.json", opportunity_attachments: opportunity.attachments)
  end

  def create(conn, %{"opportunity_id" => opportunity_id, "attachment" => attachment}) do
    opportunity = Repo.get!(Opportunity, opportunity_id)
    changeset = OpportunityAttachment.changeset(
      %OpportunityAttachment{}, %{"opportunity_id" => opportunity_id}
    )
    case Repo.insert(changeset) do
      {:ok, opportunity_attachment} ->
        {_, filename} = OpportunityAttachmentFile.store({attachment, opportunity_attachment})

        changeset = opportunity_attachment
        |> Ecto.Changeset.change(attachment: %{file_name: filename, updated_at: Ecto.DateTime.utc})

        Repo.update(changeset)
        attachment = Repo.get(OpportunityAttachment, opportunity_attachment.id)
        CercleApi.Endpoint.broadcast!(
          "opportunities:#{opportunity.id}", "opportunity:added_attachment", %{
            "opportunity" => opportunity, "attachment" => attachment
          })
        render(conn, "show.json", opportunity_attachment: attachment)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"opportunity_id" => opportunity_id, "id" => id}) do
    opportunity = Repo.get!(Opportunity, opportunity_id)
    attachment = Repo.get!(OpportunityAttachment, id)
    Repo.delete!(attachment)

    CercleApi.Endpoint.broadcast!(
      "opportunities:#{opportunity.id}", "opportunity:deleted_attachment", %{
        "opportunity" => opportunity, "attachment_id" => id
      })
    json conn, %{status: 200}
  end
end
