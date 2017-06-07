defmodule CercleApi.Oauth.TokenControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  alias CercleApi.Oauth.Token

  def last_access_token do
    ExOauth2Provider.repo.one(
      from x in ExOauth2Provider.OauthAccessTokens.OauthAccessToken,
      order_by: [desc: x.id], limit: 1
    ).token
  end

  setup %{conn: conn} do
    application = insert(:oauth_application)
    {:ok, conn: conn, application: application}
  end


  describe "as client_credentials strategy" do
    setup %{conn: conn, application: application} do
      request = %{client_id: application.uid,
                  client_secret: application.secret,
                  grant_type: "client_credentials"}

      {:ok, conn: conn,  request: request}
    end

    test "create/2", %{conn: conn, request: request} do
      conn = post conn, oauth_token_path(conn, :create, request)

      body = json_response(conn, 200)
      assert last_access_token() == body["access_token"]
      assert is_nil(body["refresh_token"])
    end

    test "create/2 with error", %{conn: conn, request: request} do
      conn = post conn, oauth_token_path(conn, :create, Map.merge(request, %{client_id: "invalid"}))
      body = json_response(conn, 422)
      assert "Client authentication failed due to unknown client, no client authentication included, or unsupported authentication method." == body["error_description"]
    end
  end



  describe "with revocation strategy" do
    setup %{conn: conn, application: application} do
      access_token = insert(:oauth_access_token, %{application: application})
      request = %{client_id: application.uid,
                  client_secret: application.secret,
                  token: access_token.token}

      {:ok, conn: conn,  request: request}
    end

    test "revoke/2", %{conn: conn, request: request} do
      conn = post conn, oauth_token_path(conn, :revoke, request)
      body = json_response(conn, 200)
      assert body == %{}
      assert ExOauth2Provider.OauthAccessTokens.is_revoked?(last_access_token())
    end

    test "revoke/2 with invalid token", %{conn: conn, request: request} do
      conn = post conn, oauth_token_path(conn, :revoke, Map.merge(request, %{token: "invalid"}))
      body = json_response(conn, 200)
      assert body == %{}
    end
  end






  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, token_path(conn, :index)
  #   assert html_response(conn, 200) =~ "Listing users"
  # end

  # test "renders form for new resources", %{conn: conn} do
  #   conn = get conn, token_path(conn, :new)
  #   assert html_response(conn, 200) =~ "New token"
  # end

  # test "creates resource and redirects when data is valid", %{conn: conn} do
  #   conn = post conn, token_path(conn, :create), token: @valid_attrs
  #   assert redirected_to(conn) == token_path(conn, :index)
  #   assert Repo.get_by(Token, @valid_attrs)
  # end

  # test "does not create resource and renders errors when data is invalid", %{conn: conn} do
  #   conn = post conn, token_path(conn, :create), token: @invalid_attrs
  #   assert html_response(conn, 200) =~ "New token"
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   token = Repo.insert! %Token{}
  #   conn = get conn, token_path(conn, :show, token)
  #   assert html_response(conn, 200) =~ "Show token"
  # end

  # test "renders page not found when id is nonexistent", %{conn: conn} do
  #   assert_error_sent 404, fn ->
  #     get conn, token_path(conn, :show, -1)
  #   end
  # end

  # test "renders form for editing chosen resource", %{conn: conn} do
  #   token = Repo.insert! %Token{}
  #   conn = get conn, token_path(conn, :edit, token)
  #   assert html_response(conn, 200) =~ "Edit token"
  # end

  # test "updates chosen resource and redirects when data is valid", %{conn: conn} do
  #   token = Repo.insert! %Token{}
  #   conn = put conn, token_path(conn, :update, token), token: @valid_attrs
  #   assert redirected_to(conn) == token_path(conn, :show, token)
  #   assert Repo.get_by(Token, @valid_attrs)
  # end

  # test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
  #   token = Repo.insert! %Token{}
  #   conn = put conn, token_path(conn, :update, token), token: @invalid_attrs
  #   assert html_response(conn, 200) =~ "Edit token"
  # end

  # test "deletes chosen resource", %{conn: conn} do
  #   token = Repo.insert! %Token{}
  #   conn = delete conn, token_path(conn, :delete, token)
  #   assert redirected_to(conn) == token_path(conn, :index)
  #   refute Repo.get(Token, token.id)
  # end
end
