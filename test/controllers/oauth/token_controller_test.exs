defmodule CercleApi.Oauth.TokenControllerTest do
  use CercleApi.ConnCase

  alias CercleApi.Oauth.Token
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, token_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, token_path(conn, :new)
    assert html_response(conn, 200) =~ "New token"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = post conn, token_path(conn, :create), token: @valid_attrs
    assert redirected_to(conn) == token_path(conn, :index)
    assert Repo.get_by(Token, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, token_path(conn, :create), token: @invalid_attrs
    assert html_response(conn, 200) =~ "New token"
  end

  test "shows chosen resource", %{conn: conn} do
    token = Repo.insert! %Token{}
    conn = get conn, token_path(conn, :show, token)
    assert html_response(conn, 200) =~ "Show token"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, token_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    token = Repo.insert! %Token{}
    conn = get conn, token_path(conn, :edit, token)
    assert html_response(conn, 200) =~ "Edit token"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    token = Repo.insert! %Token{}
    conn = put conn, token_path(conn, :update, token), token: @valid_attrs
    assert redirected_to(conn) == token_path(conn, :show, token)
    assert Repo.get_by(Token, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    token = Repo.insert! %Token{}
    conn = put conn, token_path(conn, :update, token), token: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit token"
  end

  test "deletes chosen resource", %{conn: conn} do
    token = Repo.insert! %Token{}
    conn = delete conn, token_path(conn, :delete, token)
    assert redirected_to(conn) == token_path(conn, :index)
    refute Repo.get(Token, token.id)
  end
end
