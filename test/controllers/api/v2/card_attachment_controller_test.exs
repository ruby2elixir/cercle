defmodule CercleApi.APIV2.CardAttachmentControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{CardAttachment}

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    card = insert(:card, user: user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")

    {:ok, conn: conn, user: user, card: card, company: company}
  end

  test "GET index/2 should return attachments of card",  %{conn: conn, card: card, company: company} do
    attachment = CardAttachment
    |> attach_file(insert(:card_attachment, card: card),
    :attachment, "test/fixtures/logo.png")
    response = conn
    |> get(card_card_attachment_path(conn, :index, company.id, card.id))
    |> json_response(200)

    assert response == render_json(
      CercleApi.APIV2.CardAttachmentView,
      "index.json", card_attachments: [attachment]
    )
  end

  describe "POST create/2" do
    test "create attachment of card",
      %{conn: conn, card: card, company: company} do
      CercleApi.Endpoint.subscribe("cards:#{card.id}")

      response = conn
      |> post(card_card_attachment_path(conn, :create, company, card),
      attachment: %Plug.Upload{ path: "test/fixtures/logo.png", filename: "logo.png" }
      )
      |> json_response(200)

      attach = Repo.one(from x in CardAttachment, order_by: [asc: x.id], limit: 1)
      attach_json = CardAttachment.json_data(attach)
      assert_receive %Phoenix.Socket.Broadcast{
        event: "card:added_attachment",
        payload: %{"card" => card, "attachment" => ^attach_json}
      }

      CercleApi.Endpoint.unsubscribe("cards:#{card.id}")

      assert response == render_json(
        CercleApi.APIV2.CardAttachmentView,
        "show.json", card_attachment: attach
      )
    end

  end

  describe "DELETE delete/2" do
    test "should delete attachment", %{conn: conn, card: card, company: company} do
      CercleApi.Endpoint.subscribe("cards:#{card.id}")
      attachment =  CardAttachment
      |> attach_file(insert(:card_attachment, card: card),
      :attachment, "test/fixtures/logo.png")

      attachment_id = attachment.id

      response = conn
      |> delete(card_card_attachment_path(conn, :delete, company.id, card.id, attachment_id))
      |> json_response(200)

      assert_receive %Phoenix.Socket.Broadcast{
        event: "card:deleted_attachment",
        payload: %{"card" => card, "attachment_id" => attachment_id}
      }
      CercleApi.Endpoint.unsubscribe("cards:#{card.id}")
      assert Repo.get(CardAttachment, attachment_id) == nil
      assert response == %{"status" => 200}
    end
  end
end
