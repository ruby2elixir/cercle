defmodule CercleApi.APIV2.UserController do
  use CercleApi.Web, :controller

  alias CercleApi.User
  alias CercleApi.{Company, Organization}

  plug CercleApi.Plug.EnsureAuthenticated
  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    current_user = CercleApi.Plug.current_user(conn)
    company = current_company(conn, current_user)
    query = from u in User,
      where: u.company_id == ^company.id,
      order_by: [desc: u.updated_at]

    users = query
    |> Repo.all

    render(conn, "index.json", users: users)
  end

end
