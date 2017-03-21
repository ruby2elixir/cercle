defmodule CercleApi.APIV2.ContactControllerTest do
  use CercleApi.ConnCase
  @valid_attrs %{name: "John Doe"}
  @invalid_attrs %{}
  alias CercleApi.{User,Contact}

  setup %{conn: conn} do
    company = insert_company()
    user = insert_user(username: "test", company_id: company.id)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn}
  end

  test "create contact on post", %{conn: conn} do
    conn = post conn, "/api/v2/contact", contact: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
  end

end
