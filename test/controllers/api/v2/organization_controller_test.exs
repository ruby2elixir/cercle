defmodule CercleApi.APIV2.OrganizationControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: company}
  end

  test "#index responds with all organizations", state  do
    org = insert(:organization, data: %{})
    conn = get state[:conn], "/api/v2/organizations"
    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.OrganizationView, "index.json", %{ organizations: [org] }
    )
  end

  test "#index responds organizations by user", state  do
    insert(:organization, data: %{})
    org = insert(:organization, data: %{}, company: state[:company])
    conn = get state[:conn], "/api/v2/organizations", user_id: state[:user].id
    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.OrganizationView, "index.json", %{ organizations: [org] }
    )
  end

   test "try to show authorized Organization", state do
    organization = insert(:organization,
      name: "Org1", user: state[:user], company: state[:company]
    )
    conn = get state[:conn], "/api/v2/organizations/#{organization.id}"
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to show unauthorized Organization", state do
    organization = insert(:organization, name: "Org1")
    conn = get state[:conn], "/api/v2/organizations/#{organization.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete unauthorized organization", state do
    organization = insert(:organization, name: "Org1")
    conn = delete state[:conn], "/api/v2/organizations/#{organization.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete authorized organization", state do
    organization = insert(:organization,
      name: "Org1", user: state[:user], company: state[:company]
    )
    conn = delete state[:conn], "/api/v2/organizations/#{organization.id}"
    assert json_response(conn, 200)
  end

  test "try to update authorized organization with valid params", state do
    organization = insert(:organization,
      name: "Org1", user: state[:user], company: state[:company]
    )
    conn = put state[:conn], "/api/v2/organizations/#{organization.id}", organization: %{name: "Modified Org1"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized organization", state do
    organization = insert(:organization, name: "Org1")
    conn = put state[:conn], "/api/v2/organizations/#{organization.id}", organization: %{name: "Modified Org1"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

end
