defmodule CercleApi.APIV2.CardControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{Card, CardAttachment}

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    organization = insert(:organization,
      company: company, user: user
    )
    contact = insert(:contact,
      company: company, organization: organization, user: user
    )
    board = insert(:board, company: company)
    board_column = insert(:board_column, board: board)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {
      :ok, conn: conn,
      user: user, organization: organization,
      contact: contact, company: company,
      board: board, board_column: board_column
    }
  end

  test "index/2 all cards", state do
    card_open = insert(:card, status: 0, user: state[:user],
      contact_ids: [state[:contact].id], company: state[:company]
    )
    |> Repo.preload([:board_column, board: [:board_columns]])
    card_closed = insert(:card, status: 1, user: state[:user],
      contact_ids: [state[:contact].id], company: state[:company]
    )
    |> Repo.preload([:board_column, board: [:board_columns]])

    conn = get state[:conn], "/api/v2/company/#{state[:company].id}/card", contact_id: state[:contact].id, archived: "true"

    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.CardView, "index.json", %{cards: [card_closed, card_open]}
    )
  end

  test "index/2 open cards", state do
    card_open = insert(:card, status: 0, user: state[:user],
      contact_ids: [state[:contact].id], company: state[:company]
    )
    |> Repo.preload([:board_column, board: [:board_columns]])
    _card_closed = insert(:card, status: 1, user: state[:user],
      contact_ids: [state[:contact].id], company: state[:company]
    )
    |> Repo.preload([:board_column, board: [:board_columns]])

    conn = get state[:conn], "/api/v2/company/#{state[:company].id}/card", contact_id: state[:contact].id, archived: "false"

    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.CardView, "index.json", %{ cards: [card_open] }
    )
  end

  test "index/2 cards with a specific board_column_id", state do
    card = insert(:card, status: 0, user: state[:user],
      contact_ids: [state[:contact].id], company: state[:company]
    )
    |> Repo.preload([:board_column, board: [:board_columns]])

    conn = get state[:conn], "/api/v2/company/#{state[:company].id}/card", board_column_id: card.board_column_id

    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.CardView, "cards_with_main_contact.json", %{ cards: [card] }
    )
  end

  test "try to delete authorized Card", state do
    card = insert(:card, user: state[:user], company: state[:company])
    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/card/#{card.id}"
    assert json_response(conn, 200)
  end

  test "try to delete unauthorized Card", state do
    card = insert(:card, user: state[:user], contact_ids: [state[:contact].id])
    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/card/#{card.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to update authorized Card", state do
    card = insert(:card, user: state[:user], contact_ids: [state[:contact].id], company: state[:company])
    conn = put state[:conn], "/api/v2/company/#{state[:company].id}/card/#{card.id}", card: %{name: "Modified Card"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized Card", state do
    card = insert(:card, user: state[:user])
    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/card/#{card.id}", card: %{name: "Modified Card"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "deleting card should delete attachments", state do
    card = insert(:card, user: state[:user], company: state[:company])
    attachment =  CardAttachment
    |> attach_file(insert(:card_attachment, card: card),
    :attachment, "test/fixtures/logo.png")

    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/card/#{card.id}"
    assert json_response(conn, 200)

    # Ensure attachment is deleted
    attachment = Repo.get(CardAttachment, attachment.id)
    assert attachment == nil
  end


  test "deleting card with notification", %{user: user, company: company} = state do
    card = insert(:card, due_date: Timex.now(), user: user, company: company)
    CercleApi.ActivityService.add(card)
    assert Repo.aggregate(CercleApi.Notification, :count, :id) == 2
    conn = delete state[:conn], "/api/v2/company/#{company.id}/card/#{card.id}"
    assert json_response(conn, 200)

    assert Repo.aggregate(CercleApi.Notification, :count, :id) == 0
  end

  #test "POST/2 create card", state do
  #  CercleApi.Endpoint.subscribe("cards:1")
  #
  #  response = state[:conn]
  #  |> post(
  #    card_path(state[:conn], :create, state[:company].id), card: %{
  #      board_id: state[:board].id,
  #      board_column_id: state[:board_column].id,
  #      name: "Test Card", status: 0, company: state[:company].id,
  #      user_id: state[:user].id,
  #      contact_ids: [1]
  #    }
  #  )
  #  |> json_response(201)
  #
  #  card = from(x in Card,
  #    order_by: [asc: x.id], limit: 1,
  #    preload: [:user, :board_column, board: [:board_columns]]
  #  )
  #  |> Repo.one
  #
  #  assert_receive %Phoenix.Socket.Broadcast{
  #    topic: "cards:1", event: "card:created", payload: %{"card" => _}
  #  }
  #  CercleApi.Endpoint.unsubscribe("cards:1")
  #  assert response == render_json(
  #    CercleApi.APIV2.CardView, "show.json", card: card
  #  )
  #end

  test "PUT update card", state do
    card = insert(:card, status: 0, user: state[:user],
      contact_ids: [state[:contact].id], company: state[:company]
    )
    card_channel = "cards:#{card.id}"
    CercleApi.Endpoint.subscribe(card_channel)
    board_column = insert(:board_column, board: state[:board])
    due_date = Timex.format!(Timex.today, "%F 21:00:00", :strftime)
    response = state[:conn]
    |> put(
      card_path(state[:conn], :update, state[:company].id, card), card: %{
        board_column_id: board_column.id, due_date: due_date
      }
    )
    |> json_response(200)

    assert_receive %Phoenix.Socket.Broadcast{
      topic: card_channel, event: "card:updated",
      payload: %{"card" => _, "card_contacts" => _, "board" => _, "board_columns" => _}
    }
    CercleApi.Endpoint.unsubscribe(card_channel)
    updated_card = Card
    |> Repo.get(card.id)
    |> Repo.preload([:board_column, board: [:board_columns]])

    assert response == render_json(
      CercleApi.APIV2.CardView, "show.json", card: updated_card
    )
    assert Timex.format!(updated_card.due_date, "%F %T", :strftime) == due_date
  end
end
