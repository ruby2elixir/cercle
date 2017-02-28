defmodule CercleApi.PasswordControllerTest do
  use CercleApi.ConnCase

  test "GET /forget-password", %{conn: conn} do
    conn = get conn, "/forget-password"
    assert html_response(conn, 200) =~ "Reset Password"
  end
end
