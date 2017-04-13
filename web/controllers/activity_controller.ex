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

    %{year: year, month: month, day: day} = Timex.now(current_user_time_zone)

    {:ok, date} = Date.new(year, month, day)
    date_erl = Date.to_erl(date)
    from_time = Ecto.DateTime.from_erl({date_erl, {0, 0, 0}})
    to_time = Ecto.DateTime.from_erl({date_erl, {23, 59, 59}})

    query_overdue = from p in Activity,
      where: p.is_done == false,
      where: p.user_id == ^current_user_id,
      where: p.company_id == ^company_id,
      where: p.due_date  <= ^from_time,
      order_by: [asc: p.due_date]

    activities_overdue =  Repo.preload(Repo.all(query_overdue), [:contact, :user])

    query_today = from p in Activity,
      where: p.is_done == false,
      where: p.user_id == ^current_user_id,
      where: p.company_id == ^company_id,
      where: p.due_date  >= ^from_time,
      where: p.due_date <= ^to_time,
      order_by: [asc: p.due_date]

    activities_today = Repo.preload(Repo.all(query_today), [:contact, :user])

    query_later = from p in Activity,
      where: p.is_done == false,
      where: p.user_id == ^current_user_id,
      where: p.company_id == ^company_id,
      where: p.due_date >= ^to_time,
      order_by: [asc: p.due_date]

    activities_later = Repo.preload(Repo.all(query_later), [:contact, :user])

    conn
      |> put_layout("adminlte.html")
      |> render("index.html", activities_today: activities_today, activities_overdue: activities_overdue, activities_later: activities_later, company: company, current_user_id: current_user_id, current_user_time_zone: current_user_time_zone)
  end

end
