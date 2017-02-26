defmodule CercleApi.PageControllerTest do
  use CercleApi.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Register"
    assert html_response(conn, 200) =~ "Login"
  end
end
