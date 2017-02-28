defmodule CercleApi.SessionControllerTest do
  use CercleApi.ConnCase

  test "GET /login", %{conn: conn} do
    conn = get conn, "/login"
    assert html_response(conn, 200) =~ "Sign In"
  end
end
