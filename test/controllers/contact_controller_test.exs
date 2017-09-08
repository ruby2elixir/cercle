defmodule CercleApi.ContactControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    {:ok, conn: conn, user: user, company: company}
  end

  test "GET /contacts without Authentification", %{conn: conn, company: company} do
    conn = get conn, "/company/#{company.id}/contact"
    assert html_response(conn, 302) =~ "redirected"
  end
end
