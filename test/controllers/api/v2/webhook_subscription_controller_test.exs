defmodule CercleApi.APIV2.WebhookSubscriptionControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{WebhookSubscription}

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: user.company}
  end

  test "subscribe to webhooks", state do
    conn = post state[:conn], "/api/v2/webhooks", webhook_subscription: %{event: "contact.created", url: "http://example.com/hook"}
    assert json_response(conn, 201)["data"]["id"]
  end

  test "try to update webhook subscription", state do
    conn = post state[:conn], "/api/v2/webhooks", webhook_subscription: %{event: "contact.created", url: "http://example.com/hook2"}
    assert json_response(conn, 201)["data"]["id"]
  end

  test "try to unsubscribe webhook", state do
    changeset = WebhookSubscription.changeset(%WebhookSubscription{}, %{event: "contact.created", url: "http://example.com/hook", user_id: state[:user].id})
    board_column = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/webhooks/contact.created"
    assert json_response(conn, 200)
  end
end
