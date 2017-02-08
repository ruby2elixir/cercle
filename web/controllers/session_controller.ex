defmodule CercleApi.SessionController do
  use CercleApi.Web, :controller

  alias CercleApi.User
  alias Passport.Session

  def new(conn, _) do
    conn
    |> render(:new)
  end

  def create(conn, %{"login" => login, "password" => pass}) do
    case Session.login(conn, login, pass) do
    {:ok, conn} ->
      path = get_session(conn, :redirect_url) || "/activity"
      conn
      |> put_flash(:info, "Welcome back!")
      |> redirect(to: path)
    {:error, _reason, conn} ->
      conn
      |> put_flash(:error, "Invalid username/password combination")
      |> render(:new)
    end
  end

  def delete(conn, _) do
    conn
    |> Session.logout()
    |> put_flash(:info, "You have been logged out")
    |> redirect(to: session_path(conn, :new))
  end
end
