defmodule CercleApi.APIV2.UserController do
  use CercleApi.Web, :controller

  alias CercleApi.User

  plug CercleApi.Plug.EnsureAuthenticated
  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    CercleApi.Plug.current_user(conn)
    company = current_company(conn)
    users = User.company_users(company)

    render(conn, "index.json", users: users)
  end

end
