defmodule CercleApi.APIV2.ContactControllerTest do
  use CercleApi.ConnCase
  @valid_attrs %{name: "John Doe"}
  @invalid_attrs %{}
  alias CercleApi.{Contact}

  setup %{conn: conn} do
    company = insert_company()
    user = insert_user(username: "test", company_id: company.id)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: company}
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

end
