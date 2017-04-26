defmodule CercleApi.APIV2.OpportunityAttachmentControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{Contact, Opportunity, OpportunityAttachment, OpportunityAttachmentFile}

  setup %{conn: conn} do
    user = insert(:user)
    opportunity = insert(:opportunity, user: user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")

    {:ok, conn: conn, user: user, opportunity: opportunity}
  end

  test "GET index/2 should return attachments of opportunity", %{conn: conn, opportunity: opportunity} do
    attachment_attrs = %{ attachment: %Plug.Upload{ path: "test/fixtures/logo.png", filename: "logo.png" } }

    attachment = insert(:opportunity_attachment, opportunity: opportunity)
    |> OpportunityAttachment.changeset(attachment_attrs)
    |> Repo.update!

    response = conn
    |> get(opportunity_opportunity_attachment_path(conn, :index, opportunity.id))
    |> json_response(200)

    assert response == render_json(
      CercleApi.APIV2.OpportunityAttachmentView,
      "index.json", attachments: [attachment]
    )
  end

  test "POST create/2 create attachment of opportunity", %{conn: conn, opportunity: opportunity} do
    post conn,
      opportunity_opportunity_attachment_path(conn, :create, opportunity.id),
      attachment: %Plug.Upload{ path: "test/fixtures/logo.png", filename: "logo.png" }

  end

  test "DELETE delete/2 create attachment of opportunity", state do

  end
end
