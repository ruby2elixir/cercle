defmodule CercleApi.SessionControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  test "GET /login", %{conn: conn} do
    conn = get conn, "/login"
    assert html_response(conn, 200) =~ "Sign In"
  end

  describe "POST create/2" do
    test "invalid password", %{conn: conn} do
      conn = conn
      |> post("/login", login: "12345", password: "123456", "time_zone": "Europe/Moscow")

      assert html_response(conn, 200) =~ "Invalid username/password combination"
    end

    test "valid credentials", %{conn: conn} do
      user = insert(:user,
        login: "testuser",
        password: "1234",
        password_hash: "$2b$12$uYVXG6Fm6Tl/1zLMKW1u0uFnM41HB96imoOyxzKHfeyFB69zeAD8W")
      company = insert(:company)
      add_company_to_user(user, company)

      conn = conn
      |> post("/login", "login":  "testuser", "password": "1234", "time_zone": "Europe/Moscow")
      assert redirected_to(conn) == "/company/#{company.id}/board"
    end

    test "valid credentials (without company)", %{conn: conn} do
      user = insert(:user,
        login: "testuser",
        password: "1234",
        password_hash: "$2b$12$uYVXG6Fm6Tl/1zLMKW1u0uFnM41HB96imoOyxzKHfeyFB69zeAD8W")

      conn = conn
      |> post("/login", "login":  "testuser", "password": "1234", "time_zone": "Europe/Moscow")
      assert redirected_to(conn) =~ ~r/\/company\/\d+\/board/
    end
  end

  test "delete/2", %{ conn: conn } do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = conn
    |> put_req_header("authorization", "Bearer #{jwt}")
    |> get("/logout")
    assert redirected_to(conn) == "/login"
  end
end
