defmodule CercleApi.APIV2.ActivityController do

  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{Contact, Activity, Repo}

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "activity" when action in [:create, :update]

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)
    current_user_id = current_user.id
    current_user_time_zone = current_user.time_zone
    company_id = current_user.company_id

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
      where: not is_nil(p.contact_id),
      order_by: [asc: p.due_date]

    activities_overdue = Repo.all(query_overdue)
    |> Repo.preload([:contact, :user])

    query_today = from p in Activity,
      where: p.is_done == false,
      where: p.user_id == ^current_user_id,
      where: p.company_id == ^company_id,
      where: p.due_date  >= ^from_time,
      where: p.due_date <= ^to_time,
      order_by: [asc: p.due_date]

    activities_today = Repo.all(query_today)
    |> Repo.preload([:contact, :user])

    query_later = from p in Activity,
      where: p.is_done == false,
      where: p.user_id == ^current_user_id,
      where: p.company_id == ^company_id,
      where: p.due_date >= ^to_time,
      order_by: [asc: p.due_date]

    activities_later = Repo.all(query_later)
    |> Repo.preload([:contact, :user])
    render(conn, "list.json",
      activities_today: activities_today,
      activities_overdue: activities_overdue,
      activities_later: activities_later
    )
  end

  def create(conn, %{"activity" => activity_params}) do
    current_user = Guardian.Plug.current_resource(conn)
    changeset = current_user
    |> build_assoc(:activities)
    |> Activity.changeset(activity_params)

    case Repo.insert(changeset) do
      {:ok, activity} ->
        activity = activity
        |> Repo.preload([:user])
        CercleApi.Endpoint.broadcast!(
          "opportunities:" <> to_string(activity.opportunity_id),
          "activity:created", %{"activity" => activity}
        )
        json conn, "{OK: true}"
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "activity" => activity_params}) do
    activity = Repo.get!(Activity, id)
    |> Repo.preload(:user)

    changeset = Activity.changeset(activity, activity_params)

    case Repo.update(changeset) do
      {:ok, activity} ->
        CercleApi.Endpoint.broadcast!(
          "opportunities:" <> to_string(activity.opportunity_id),
          "activity:updated", %{"activity" => activity}
        )
        render(conn, "show.json", activity: activity)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    activity = Repo.get!(Activity, id)
    channel = "opportunities:" <> to_string(activity.opportunity_id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(activity)

    CercleApi.Endpoint.broadcast!(
      channel, "activity:deleted", %{"activity_id" => id}
    )

    send_resp(conn, :no_content, "")
  end

end
