defmodule CercleApi.APIV2.ContactControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  @valid_attrs %{name: "John Doe"}
  @invalid_attrs %{}
  alias CercleApi.{Contact, TimelineEvent, Opportunity}

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
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", company_id: state[:company].id})
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

  test "deleting contact should delete opportunity if it is the only contact", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", user_id: state[:user].id, company_id: state[:company].id})
    contact = Repo.insert!(changeset)

    changeset = Opportunity.changeset(%Opportunity{}, %{main_contact_id: contact.id, contact_ids: [contact.id], user_id: state[:user].id, company_id: state[:company].id})
    opportunity = Repo.insert!(changeset)

    old_count = Repo.one(from p in Opportunity, select: count("*"))

    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Test no of opportunities after delete
    new_count = Repo.one(from p in Opportunity, select: count("*"))
    assert old_count-1 == new_count

    # Ensure opportunity is deleted, as it had only one contact which is deleted
    opportunity = Repo.get(Opportunity, opportunity.id)
    assert opportunity == nil
  end

  test "deleting contact should update opportunity if it has other contacts", state do
    changeset = Contact.changeset(%Contact{}, %{name: "Contact1", user_id: state[:user].id, company_id: state[:company].id})
    contact = Repo.insert!(changeset)

    changeset = Contact.changeset(%Contact{}, %{name: "Contact2", user_id: state[:user].id, company_id: state[:company].id})
    contact2 = Repo.insert!(changeset)

    changeset = Opportunity.changeset(%Opportunity{}, %{main_contact_id: contact.id, contact_ids: [contact.id, contact2.id], user_id: state[:user].id, company_id: state[:company].id})
    opportunity = Repo.insert!(changeset)

    assert opportunity.contact_ids == [contact.id, contact2.id]

    conn = delete state[:conn], "/api/v2/contact/#{contact.id}"
    assert json_response(conn, 200)

    # Check for the new main_contact_id for opportunity2
    opportunity = Repo.get(Opportunity, opportunity.id)
    assert opportunity.main_contact_id == contact2.id
    assert opportunity.contact_ids == [contact2.id]
  end

end
