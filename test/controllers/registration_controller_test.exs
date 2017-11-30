defmodule CercleApi.RegistrationControllerTest do
  use CercleApi.ConnCase
  alias CercleApi.{ Repo, User }
  @valid_attrs %{
    user: %{full_name: "test-user", login: "test@test.com", password: "123456"},
    company: %{ title: "TestCompany" }
  }
  test "GET /register", %{conn: conn} do
    conn = get conn, "/register"
    assert html_response(conn, 200) =~ "Sign up"
  end
  describe "POST create/2" do
    test "valid data /register", %{conn: conn} do
      conn = post(conn, "/register", @valid_attrs)
      assert redirected_to(conn) =~ ~r/company\/\d+\/board/
      user = Repo.get_by(User, login: "test@test.com")
      assert user.full_name
    end
  end
end
