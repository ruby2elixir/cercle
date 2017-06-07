defmodule CercleApi.Admin.OauthApplicationControllerTest do
  use CercleApi.ConnCase

  alias CercleApi.Admin.OauthApplication
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, oauth_application_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing users"
  # end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, oauth_application_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New oauth application"
  # end

  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, oauth_application_path(conn, :create), oauth_application: @valid_attrs
  #   assert redirected_to(conn) == oauth_application_path(conn, :index)
  #   assert Repo.get_by(OauthApplication, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, oauth_application_path(conn, :create), oauth_application: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New oauth application"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   oauth_application = Repo.insert! %OauthApplication{}
  #   conn = get conn, oauth_application_path(conn, :show, oauth_application)
  #   assert html_response(conn, 200) =~ "Show oauth application"
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, oauth_application_path(conn, :show, -1)
  #   end
  # end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   oauth_application = Repo.insert! %OauthApplication{}
  #   conn = get conn, oauth_application_path(conn, :edit, oauth_application)
  #   assert html_response(conn, 200) =~ "Edit oauth application"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   oauth_application = Repo.insert! %OauthApplication{}
  #   conn = put conn, oauth_application_path(conn, :update, oauth_application), oauth_application: @valid_attrs
  #   assert redirected_to(conn) == oauth_application_path(conn, :show, oauth_application)
  #   assert Repo.get_by(OauthApplication, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   oauth_application = Repo.insert! %OauthApplication{}
  #   conn = put conn, oauth_application_path(conn, :update, oauth_application), oauth_application: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit oauth application"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   oauth_application = Repo.insert! %OauthApplication{}
  #   conn = delete conn, oauth_application_path(conn, :delete, oauth_application)
  #   assert redirected_to(conn) == oauth_application_path(conn, :index)
  #   refute Repo.get(OauthApplication, oauth_application.id)
  # end
end
