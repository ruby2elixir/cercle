defmodule CercleApi.APIV2.UserProfileController do
  use CercleApi.Web, :controller

  alias CercleApi.User

  plug CercleApi.Plug.EnsureAuthenticated
  def show(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"user" => user_params}) do
     user = Guardian.Plug.current_resource(conn)
     changeset = User.update_changeset(user, user_params)
     company = current_company(conn)

     case Repo.update(changeset) do
       {:ok, user} ->
         render(conn, "show.json", user: user)
       {:error, changeset} ->
         render(conn, "show.json", user: user)
     end
   end
end
