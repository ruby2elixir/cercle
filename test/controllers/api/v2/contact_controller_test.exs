defmodule CercleApi.APIV2.ContactControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  @valid_attrs %{first_name: "John", last_name: "Doe"}
  alias CercleApi.{Board, BoardColumn, Contact, TimelineEvent, Card, CardAttachment}

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: company}
  end

  test "index/2 responds with all Contacts", state do
    contacts_data = [ Contact.changeset(%Contact{}, %{first_name: "John", last_name: "Doe", company_id: state[:company].id}),
                 Contact.changeset(%Contact{}, %{first_name: "Jane", last_name: "Doe", company_id: state[:company].id}) ]

    Enum.each(contacts_data, &Repo.insert!(&1))
    query = from p in Contact,
      where: p.company_id == ^state[:company].id,
      order_by: [desc: p.updated_at]

    contacts = query
    |> Repo.all
    |> Repo.preload(
      [ :organization, :tags,
        timeline_event: from(TimelineEvent, order_by: [desc: :inserted_at])
      ]
    )

    response = get(state[:conn], "/api/v2/company/#{state[:company].id}/contact")
    |> json_response(200)


    assert response == render_json(
      CercleApi.APIV2.ContactView, "index.json", contacts: contacts
    )
  end

  test "create contact with valid params", %{conn: conn} = state do
    conn = post conn, "/api/v2/company/#{state[:company].id}/contact", contact: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
  end

  test "create contact with name instead of fist_name and last_name", %{conn: conn} = state do
    conn = post conn, "/api/v2/company/#{state[:company].id}/contact", contact: %{name: "John Doe"}
    assert json_response(conn, 201)["data"]["id"]
    assert json_response(conn, 201)["data"]["first_name"]
    assert json_response(conn, 201)["data"]["last_name"]
  end

  test "create contact with update_or_create mode", %{conn: conn} = state do
    response = conn
    |> post("/api/v2/company/#{state[:company].id}/contact", contact: %{email: "contact@test.com", name: "John Doe"})
    |> json_response(201)
    assert response["data"]["id"]
    assert response["data"]["email"] == "contact@test.com"
    assert response["data"]["name"] == "John Doe"
    assert Repo.aggregate(Contact, :count, :id) == 1

    response = conn
    |> post("/api/v2/company/#{state[:company].id}/contact", contact: %{email: "contact@test.com", name: "S John Doe"})
    |> json_response(201)
    assert response["data"]["id"]
    assert response["data"]["email"] == "contact@test.com"
    assert response["data"]["name"] == "S John Doe"
    assert Repo.aggregate(Contact, :count, :id) == 2

    response = conn
    |> post("/api/v2/company/#{state[:company].id}/contact", update_or_create: "true",
    contact: %{email: "contact@test.com", name: "Little John Doe"})
    |> json_response(200)
    assert response["data"]["email"] == "contact@test.com"
    assert response["data"]["name"] == "Little John Doe"
    assert Repo.aggregate(Contact, :count, :id) == 2

    response = conn
    |> post("/api/v2/company/#{state[:company].id}/contact", update_or_create: "false",
    contact: %{email: "contact@test.com", name: "Little John Doe"})
    |> json_response(201)
    assert response["data"]["email"] == "contact@test.com"
    assert response["data"]["name"] == "Little John Doe"
    assert Repo.aggregate(Contact, :count, :id) == 3
  end

  test "try to update authorized contact with valid params", state do
    contact = insert(:contact, user: state[:user], company: state[:company])
    conn = put state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}", contact: %{name: "Modified Contact"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized contact", state do
    contact = insert(:contact)
    conn = put state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}", contact: %{name: "Modified Contact"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to show authorized contact", state do
    contact = insert(:contact, user: state[:user], company: state[:company])
    conn = get state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}", user_id: state[:user].id, company_id: state[:company].id
    assert json_response(conn, 200)["data"]
  end

  test "try to show unauthorized contact", state do
    contact = insert(:contact)
    conn = get state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}", user_id: state[:user].id, company_id: state[:company].id
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete unauthorized contact", state do
    contact = insert(:contact)
    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete authorized contact", state do
    contact = insert(:contact, user: state[:user], company: state[:company])
    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}"
    assert json_response(conn, 200)
  end

  test "multiple_delete", state do
    contact = insert(:contact, user: state[:user], company: state[:company])
    contact1 = insert(:contact)
    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/contact/multiple/delete", contact_ids: [contact.id, contact1.id]
    assert Repo.get(Contact, contact.id) == nil
    assert Repo.get(Contact, contact1.id).id == contact1.id
    assert json_response(conn, 200)
  end

  test "deleting contact should delete card if it is the only contact", state do
    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id, user_id: state[:user].id})
    board = Repo.insert!(changeset)

    contact = insert(:contact, user: state[:user], company: state[:company])
    card = insert(:card, contact_ids: [contact.id], user: state[:user], company: state[:company], board: board)

    old_count = Repo.one(from p in Card, select: count("*"))

    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Test no of cards after delete
    new_count = Repo.one(from p in Card, select: count("*"))
    assert old_count-1 == new_count

    # Ensure card is deleted, as it had only one contact which is deleted
    card = Repo.get(Card, card.id)
    assert card == nil
  end

  test "deleting contact should delete card and its attachments", state do
    contact = insert(:contact, user: state[:user], company: state[:company])
    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id, user_id: state[:user].id})
    board = Repo.insert!(changeset)

    card = insert(:card, contact_ids: [contact.id], user: state[:user], company: state[:company], board: board)

    attachment =  CardAttachment
    |> attach_file(insert(:card_attachment, card: card),
    :attachment, "test/fixtures/logo.png")

    old_count = Repo.one(from p in Card, select: count("*"))

    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Test no of cards after delete
    new_count = Repo.one(from p in Card, select: count("*"))
    assert old_count-1 == new_count

    # Ensure card is deleted, as it had only one contact which is deleted
    card = Repo.get(Card, card.id)
    assert card == nil

    # Ensure attachment is deleted
    attachment = Repo.get(CardAttachment, attachment.id)
    assert attachment == nil
  end

  test "deleting contact should update card if it has other contacts", state do
    contact = insert(:contact, user: state[:user], company: state[:company])
    contact2 = insert(:contact, user: state[:user], company: state[:company])
    card = insert(:card, company: state[:company], contact_ids: [contact.id, contact2.id], user: state[:user])

    assert card.contact_ids == [contact.id, contact2.id]

    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}"
    assert json_response(conn, 200)

    card = Repo.get(Card, card.id)
    assert card.contact_ids == [contact2.id]
  end

  test "deleting contact should delete associated timeline events", state do
    contact = insert(:contact, user: state[:user], company: state[:company])
    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id, user_id: state[:user].id})
    board = Repo.insert!(changeset)

    changeset = BoardColumn.changeset(%BoardColumn{}, %{name: "Step1", order: "1", board_id: board.id})
    board_column = Repo.insert!(changeset)

    changeset = Card.changeset(%Card{}, %{contact_ids: [contact.id], user_id: state[:user].id, company_id: state[:company].id, board_id: board.id, board_column_id: board_column.id, name: "Test Card"})
    card = Repo.insert!(changeset)

    changeset = TimelineEvent.changeset(%TimelineEvent{}, %{card_id: card.id, contact_id: contact.id, user_id: state[:user].id, company_id: state[:company].id, event_name: "test", content: "test"})
    timeline_event = Repo.insert!(changeset)

    old_count = Repo.one(from p in TimelineEvent, select: count("*"))

    conn = delete state[:conn], "/api/v2/company/#{state[:company].id}/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Test no of timeline events after delete
    new_count = Repo.one(from p in TimelineEvent, select: count("*"))
    assert old_count-1 == new_count

    # timeline_event should be nil after deleting contact
    timeline_event = Repo.get(TimelineEvent, timeline_event.id)
    assert timeline_event == nil
  end
end
