defmodule CercleApi.RegistrationControllerTest do
  use CercleApi.ConnCase

  test "GET /register", %{conn: conn} do
    conn = get conn, "/register"
    assert html_response(conn, 200) =~ "Sign Up"
  end
end
