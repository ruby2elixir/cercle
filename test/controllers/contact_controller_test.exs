defmodule CercleApi.ContactControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, conn: conn, user: user}
  end

  test "GET /contacts without Authentification", %{conn: conn} do
    conn = get conn, "/contact"
    assert html_response(conn, 302) =~ "redirected"
  end
end
