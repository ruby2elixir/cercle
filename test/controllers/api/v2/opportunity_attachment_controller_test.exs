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
    attachment = OpportunityAttachment
    |> attach_file(insert(:opportunity_attachment, opportunity: opportunity),
    :attachment, "test/fixtures/logo.png")

    response = conn
    |> get(opportunity_opportunity_attachment_path(conn, :index, opportunity.id))
    |> json_response(200)

    assert response == render_json(
      CercleApi.APIV2.OpportunityAttachmentView,
      "index.json", opportunity_attachments: [attachment]
    )
  end

  describe "POST create/2" do
    test "create attachment of opportunity", %{conn: conn, opportunity: opportunity} do
      response = conn
      |> post(opportunity_opportunity_attachment_path(conn, :create, opportunity.id),
      attachment: %Plug.Upload{ path: "test/fixtures/logo.png", filename: "logo.png" }
      )
      |> json_response(200)

      [attach|_] = Repo.all(OpportunityAttachment)

      assert response == render_json(
        CercleApi.APIV2.OpportunityAttachmentView,
        "show.json", opportunity_attachment: attach
      )
    end

    test "return error if attachment empty", %{conn: conn, opportunity: opportunity} do
      response = conn
      |> post(opportunity_opportunity_attachment_path(conn, :create, opportunity.id),
      attachment: ""
      )
      |> json_response(422)

      assert response == %{"errors" => %{"attachment" => ["can't be blank"]}}
    end
  end

  describe "DELETE delete/2" do
    test "should delete attachment", %{conn: conn, opportunity: opportunity} do
      attachment =  OpportunityAttachment
      |> attach_file(insert(:opportunity_attachment, opportunity: opportunity),
      :attachment, "test/fixtures/logo.png")

      response = conn
      |> delete(opportunity_opportunity_attachment_path(
            conn, :delete, opportunity.id, attachment.id))
      |> json_response(200)
      assert Repo.get(OpportunityAttachment, attachment.id) == nil
      assert response == %{"status" => 200}
    end
  end
end
