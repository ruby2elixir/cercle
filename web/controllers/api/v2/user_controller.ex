defmodule CercleApi.APIV2.UserController do
  use CercleApi.Web, :controller

  alias CercleApi.User
  alias CercleApi.{Company, Organization}

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    company_id  = current_user.company_id
    query = from u in User,
      where: u.company_id == ^company_id,
      order_by: [desc: u.updated_at]

    users = query
    |> Repo.all

    render(conn, "index.json", users: users)
  end

  def organizations(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    company_id = current_user.company_id
    query = from p in Organization,
      where: p.company_id == ^company_id,
      order_by: [desc: p.inserted_at]
    organizations = Repo.all(query)

    render(conn, "organizations.json", organizations: organizations)
  end
end
