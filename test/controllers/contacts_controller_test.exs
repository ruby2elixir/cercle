defmodule CercleApi.ContactsControllerTest do
  use CercleApi.ConnCase

  test "GET /contacts without Authentification", %{conn: conn} do
    conn = get conn, "/contacts"
    assert html_response(conn, 302) =~ "redirected"
  end
end
