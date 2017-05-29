defmodule CercleApi.APIV2.TimelineEventTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{TimelineEvent}

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: user.company}
  end

  test "timeline_event index with valid params", state do
    te = insert(:timeline_event) |> Repo.preload([:card, :user])
    conn = get state[:conn], "/api/v2/timeline_events"

    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.TimelineEventView, "index.json", timeline_events: [te]
    )
  end

  test "POST create/2", state do
    card = insert(:card, user: state[:user])
    contact = insert(:contact, user: state[:user])
    response = state[:conn]
    |> post(
      timeline_event_path(state[:conn], :create),
    timeline_event: %{"content" => "Test Content",
                      "event_name" => "comment",
                      "contact_id" => contact.id,
                      "card_id" => card.id}
    )
    |> json_response(201)

    event = Repo.one(from x in TimelineEvent, order_by: [asc: x.id], limit: 1, preload: [:user])
    assert response == render_json(
      CercleApi.APIV2.TimelineEventView,
      "show.json", timeline_event: event
    )
  end

  test "PUT update/2", state do
    te = Repo.preload(insert(:timeline_event, metadata: %{}, user: state[:user]), [:card, :user])
    response = state[:conn]
    |> put(timeline_event_path(state[:conn], :update, te),
    timeline_event: %{"content" => "Test Content1" }
    )
    |> json_response(200)

    assert response == render_json(
      CercleApi.APIV2.TimelineEventView,
      "show.json", timeline_event: %CercleApi.TimelineEvent{te|content: "Test Content1"}
    )
  end

  test "delete event", state do
    te = Repo.preload(insert(:timeline_event, user: state[:user]), [:card])
    event_id = te.id
    card_channel = "cards:#{te.card_id}"
    CercleApi.Endpoint.subscribe(card_channel)
    response = state[:conn]
    |> delete(timeline_event_path(state[:conn], :delete, event_id))
    |> json_response(200)

    assert_receive %Phoenix.Socket.Broadcast{
      event: "timeline_event:deleted", payload: %{"id" => event_id}
     }
    CercleApi.Endpoint.unsubscribe(card_channel)

    assert Repo.get(TimelineEvent, event_id) == nil
    assert response == %{"status" => 200}
  end
end
