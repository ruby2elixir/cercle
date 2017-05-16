defmodule CercleApi.APIV2.ContactControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  @valid_attrs %{name: "John Doe"}
  @invalid_attrs %{}
  alias CercleApi.{Board, Contact, TimelineEvent, Card, Activity, CardAttachment}

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: user.company}
  end

  test "index/2 responds with all Contacts", state do
    contacts_data = [ Contact.changeset(%Contact{}, %{name: "John", company_id: state[:company].id}),
                 Contact.changeset(%Contact{}, %{name: "Jane", company_id: state[:company].id}) ]

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

    response = get(state[:conn], "/api/v2/contact")
    |> json_response(200)


    assert response == render_json(
      CercleApi.APIV2.ContactView, "index.json", contacts: contacts
    )
  end

  test "create contact with valid params", %{conn: conn} do
    conn = post conn, "/api/v2/contact", contact: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
  end

  test "create contact with invalid params", %{conn: conn} do
    conn = post conn, "/api/v2/contact", contact: @invalid_attrs
    assert json_response(conn, 422)["errors"]["name"] == ["can't be blank"]
  end

  test "try to update authorized contact with valid params", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", company_id: state[:company].id, user_id: state[:user].id})
    contact = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/contact/#{contact.id}", contact: %{name: "Modified Contact"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized contact", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", company_id: state[:company].id + 1})
    contact = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/contact/#{contact.id}", contact: %{name: "Modified Contact"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to show authorized contact", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", company_id: state[:company].id, user_id: state[:user].id})
    contact = Repo.insert!(changeset)
    conn = get state[:conn], "/api/v2/contact/#{contact.id}", user_id: state[:user].id, company_id: state[:company].id
    assert json_response(conn, 200)["data"]
  end

  test "try to show unauthorized contact", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", company_id: state[:company].id + 1})
    contact = Repo.insert!(changeset)
    conn = get state[:conn], "/api/v2/contact/#{contact.id}", user_id: state[:user].id, company_id: state[:company].id
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete unauthorized contact", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", company_id: state[:company].id + 1})
    contact = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete authorized contact", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", user_id: state[:user].id, company_id: state[:company].id})
    contact = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
    assert json_response(conn, 200)
  end

  test "deleting contact should delete card if it is the only contact", state do
    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id, user_id: state[:user].id})
    board = Repo.insert!(changeset)

    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", user_id: state[:user].id, company_id: state[:company].id})
    contact = Repo.insert!(changeset)

    changeset = Card.changeset(%Card{}, %{main_contact_id: contact.id, contact_ids: [contact.id], user_id: state[:user].id, company_id: state[:company].id, board_id: board.id})
    card = Repo.insert!(changeset)

    old_count = Repo.one(from p in Card, select: count("*"))

    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Test no of cards after delete
    new_count = Repo.one(from p in Card, select: count("*"))
    assert old_count-1 == new_count

    # Ensure card is deleted, as it had only one contact which is deleted
    card = Repo.get(Card, card.id)
    assert card == nil
  end

  test "deleting contact should delete card and its attachments", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", user_id: state[:user].id, company_id: state[:company].id})
    contact = Repo.insert!(changeset)

    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id, user_id: state[:user].id})
    board = Repo.insert!(changeset)

    changeset = Card.changeset(%Card{}, %{main_contact_id: contact.id, contact_ids: [contact.id], user_id: state[:user].id, company_id: state[:company].id, board_id: board.id})
    card = Repo.insert!(changeset)

    attachment =  CardAttachment
    |> attach_file(insert(:card_attachment, card: card),
    :attachment, "test/fixtures/logo.png")

    old_count = Repo.one(from p in Card, select: count("*"))

    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
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
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", user_id: state[:user].id, company_id: state[:company].id})
    contact = Repo.insert!(changeset)

    changeset = Contact.changeset(%Contact{}, %{name: "Contact2", user_id: state[:user].id, company_id: state[:company].id})
    contact2 = Repo.insert!(changeset)

    changeset = Card.changeset(%Card{}, %{main_contact_id: contact.id, contact_ids: [contact.id, contact2.id], user_id: state[:user].id, company_id: state[:company].id})
    card = Repo.insert!(changeset)

    assert card.contact_ids == [contact.id, contact2.id]

    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Check for the new main_contact_id for card2
    card = Repo.get(Card, card.id)
    assert card.main_contact_id == contact2.id
    assert card.contact_ids == [contact2.id]
  end

  test "deleting contact should delete associated timeline events", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", user_id: state[:user].id, company_id: state[:company].id})
    contact = Repo.insert!(changeset)

    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id, user_id: state[:user].id})
    board = Repo.insert!(changeset)

    changeset = Card.changeset(%Card{}, %{main_contact_id: contact.id, contact_ids: [contact.id], user_id: state[:user].id, company_id: state[:company].id, board_id: board.id})
    card = Repo.insert!(changeset)

    changeset = TimelineEvent.changeset(%TimelineEvent{}, %{card_id: card.id, contact_id: contact.id, user_id: state[:user].id, company_id: state[:company].id, event_name: "test", content: "test"})
    timeline_event = Repo.insert!(changeset)

    old_count = Repo.one(from p in TimelineEvent, select: count("*"))

    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Test no of timeline events after delete
    new_count = Repo.one(from p in TimelineEvent, select: count("*"))
    assert old_count-1 == new_count

    # timeline_event should be nil after deleting contact
    timeline_event = Repo.get(TimelineEvent, timeline_event.id)
    assert timeline_event == nil
  end

  test "deleting contact should delete associated activities", state do
    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id, user_id: state[:user].id})
    board = Repo.insert!(changeset)

    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", user_id: state[:user].id, company_id: state[:company].id})
    contact = Repo.insert!(changeset)

    changeset = Card.changeset(%Card{}, %{main_contact_id: contact.id, contact_ids: [contact.id], user_id: state[:user].id, company_id: state[:company].id, board_id: board.id})
    card = Repo.insert!(changeset)

    changeset = Activity.changeset(%Activity{}, %{card_id: card.id, contact_id: contact.id, user_id: state[:user].id, company_id: state[:company].id, title: "test"})
    activity = Repo.insert!(changeset)

    old_count = Repo.one(from p in Activity, select: count("*"))

    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Test no of activities after delete
    new_count = Repo.one(from p in Activity, select: count("*"))
    assert old_count-1 == new_count

    # Ensure activity is deleted
    activity = Repo.get(Activity, activity.id)
    assert activity == nil
  end

end
