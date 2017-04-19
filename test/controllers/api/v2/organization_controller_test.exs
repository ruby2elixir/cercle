defmodule CercleApi.APIV2.OrganizationControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{Organization}

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: user.company}
  end

   test "try to show authorized Organization", state do
    changeset = Organization.changeset(%Organization{}, %{name: "Org1", user_id: state[:user].id, company_id: state[:company].id})
    organization = Repo.insert!(changeset)
    conn = get state[:conn], "/api/v2/organizations/#{organization.id}"
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to show unauthorized Organization", state do
    changeset = Organization.changeset(%Organization{}, %{name: "Org1", user_id: state[:user].id + 1, company_id: state[:company].id + 1})
    organization = Repo.insert!(changeset)
    conn = get state[:conn], "/api/v2/organizations/#{organization.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete unauthorized organization", state do
    changeset = Organization.changeset(%Organization{}, %{name: "Org1", user_id: state[:user].id + 1, company_id: state[:company].id + 1})
    organization = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/organizations/#{organization.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete authorized organization", state do
    changeset = Organization.changeset(%Organization{}, %{name: "Org1", user_id: state[:user].id, company_id: state[:company].id})
    organization = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/organizations/#{organization.id}"
    assert json_response(conn, 200)
  end

  test "try to update authorized organization with valid params", state do
    changeset = Organization.changeset(%Organization{}, %{name: "Org1", user_id: state[:user].id, company_id: state[:company].id})
    organization = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/organizations/#{organization.id}", organization: %{name: "Modified Org1"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized organization", state do
    changeset = Organization.changeset(%Organization{}, %{name: "Org1", user_id: state[:user].id + 1, company_id: state[:company].id + 1})
    organization = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/organizations/#{organization.id}", organization: %{name: "Modified Org1"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

end
