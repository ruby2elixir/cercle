defmodule CercleApi.ActivityController do
  use CercleApi.Web, :controller

  require Logger

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)

    current_user_id = current_user.id
    current_user_time_zone = current_user.time_zone
    company = current_company(conn)

    conn
      |> put_layout("adminlte.html")
      |> render("index.html", company: company,
    current_user_id: current_user_id,
    current_user_time_zone: current_user_time_zone,
    page: :activities
    )
  end

end
