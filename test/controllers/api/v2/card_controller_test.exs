defmodule CercleApi.APIV2.CardControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{Contact,Card, CardAttachment}

  setup %{conn: conn} do
    user = insert(:user)
    organization = insert(:organization,
      company: user.company, user: user
    )
    contact = insert(:contact,
      company: user.company, organization: organization, user: user
    )
    board = insert(:board, company: user.company)
    board_column = insert(:board_column, board: board)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {
      :ok, conn: conn,
      user: user, organization: organization,
      contact: contact, company: user.company,
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

    conn = get state[:conn], "/api/v2/card", contact_id: state[:contact].id, archived: "true"

    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.CardView, "index.json", %{cards: [card_closed, card_open]}
    )
  end

  test "index/2 open cards", state do
    card_open = insert(:card, status: 0, user: state[:user],
      contact_ids: [state[:contact].id], company: state[:company]
    )
    |> Repo.preload([:board_column, board: [:board_columns]])
    card_closed = insert(:card, status: 1, user: state[:user],
      contact_ids: [state[:contact].id], company: state[:company]
    )
    |> Repo.preload([:board_column, board: [:board_columns]])

    conn = get state[:conn], "/api/v2/card", contact_id: state[:contact].id, archived: "false"

    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.CardView, "index.json", %{ cards: [card_open] }
    )
  end

  test "try to delete authorized Card", state do
    card = insert(:card, user: state[:user], company: state[:company])
    conn = delete state[:conn], "/api/v2/card/#{card.id}"
    assert json_response(conn, 200)
  end

  test "try to delete unauthorized Card", state do
    card = insert(:card, user: state[:user], contact_ids: [state[:contact].id])
    conn = delete state[:conn], "/api/v2/card/#{card.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to update authorized Card", state do
    card = insert(:card, user: state[:user], contact_ids: [state[:contact].id], company: state[:company])
    conn = put state[:conn], "/api/v2/card/#{card.id}", card: %{name: "Modified Card"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized Card", state do
    card = insert(:card, user: state[:user])
    conn = delete state[:conn], "/api/v2/card/#{card.id}", card: %{name: "Modified Card"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "deleting card should delete attachments", state do
    card = insert(:card, user: state[:user], company: state[:company])
    attachment =  CardAttachment
    |> attach_file(insert(:card_attachment, card: card),
    :attachment, "test/fixtures/logo.png")

    conn = delete state[:conn], "/api/v2/card/#{card.id}"
    assert json_response(conn, 200)

    # Ensure attachment is deleted
    attachment = Repo.get(CardAttachment, attachment.id)
    assert attachment == nil
  end

end
