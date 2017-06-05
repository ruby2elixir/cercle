defmodule CercleApi.Oauth.AuthorizationControllerTest do
  use CercleApi.ConnCase

  alias CercleApi.Oauth.Authorization
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, authorization_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, authorization_path(conn, :new)
    assert html_response(conn, 200) =~ "New authorization"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, authorization_path(conn, :create), authorization: @valid_attrs
    assert redirected_to(conn) == authorization_path(conn, :index)
    assert Repo.get_by(Authorization, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, authorization_path(conn, :create), authorization: @invalid_attrs
    assert html_response(conn, 200) =~ "New authorization"
  end

  test "shows chosen resource", %{conn: conn} do
    authorization = Repo.insert! %Authorization{}
    conn = get conn, authorization_path(conn, :show, authorization)
    assert html_response(conn, 200) =~ "Show authorization"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, authorization_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    authorization = Repo.insert! %Authorization{}
    conn = get conn, authorization_path(conn, :edit, authorization)
    assert html_response(conn, 200) =~ "Edit authorization"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    authorization = Repo.insert! %Authorization{}
    conn = put conn, authorization_path(conn, :update, authorization), authorization: @valid_attrs
    assert redirected_to(conn) == authorization_path(conn, :show, authorization)
    assert Repo.get_by(Authorization, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    authorization = Repo.insert! %Authorization{}
    conn = put conn, authorization_path(conn, :update, authorization), authorization: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit authorization"
  end

  test "deletes chosen resource", %{conn: conn} do
    authorization = Repo.insert! %Authorization{}
    conn = delete conn, authorization_path(conn, :delete, authorization)
    assert redirected_to(conn) == authorization_path(conn, :index)
    refute Repo.get(Authorization, authorization.id)
  end
end
