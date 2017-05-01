defmodule CercleApi.ActivityController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Contact, Activity, Organization, TimelineEvent, Company}

  require Logger

  def index(conn, _params) do
    current_user = Repo.preload(Guardian.Plug.current_resource(conn), :company)

    current_user_id = current_user.id
    current_user_time_zone = current_user.time_zone
    company_id = current_user.company.id

    company = Repo.preload(Repo.get!(CercleApi.Company, company_id), [:users])

    conn
      |> put_layout("adminlte.html")
      |> render("index.html", company: company, current_user_id: current_user_id, current_user_time_zone: current_user_time_zone)
  end

end
