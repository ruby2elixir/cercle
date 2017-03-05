defmodule CercleApi.APIV2.UserController do
  use CercleApi.Web, :controller

  alias CercleApi.User
  alias CercleApi.{Company, Organization}

  plug :scrub_params, "user" when action in [:create, :update]


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
