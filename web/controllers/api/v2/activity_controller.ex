defmodule CercleApi.APIV2.ActivityController do

  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{Activity, Repo}

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "activity" when action in [:create, :update]

  def index(conn, _params) do
    current_user = Guardian.Plug.current_resource(conn)

    activities_overdue = Activity.overdue(current_user)
    activities_today = Activity.today(current_user)
    activities_later = Activity.later(current_user)
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
        |> Repo.preload([:contact, :user])
        CercleApi.Endpoint.broadcast!(
          "opportunities:" <> to_string(activity.opportunity_id),
          "activity:created", %{"activity" => activity}
        )

        CercleApi.Endpoint.broadcast!(
          "users:" <> to_string(current_user.id),
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
    current_user = Guardian.Plug.current_resource(conn)
    activity = Activity
    |> Repo.get!(id)
    |> Repo.preload(:user)

    changeset = Activity.changeset(activity, activity_params)

    case Repo.update(changeset) do
      {:ok, activity} ->
        activity = activity
        |> Repo.preload([:contact, :user])
        CercleApi.Endpoint.broadcast!(
          "opportunities:" <> to_string(activity.opportunity_id),
          "activity:updated", %{"activity" => activity}
        )

        CercleApi.Endpoint.broadcast!(
          "users:" <> to_string(current_user.id),
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
    current_user = Guardian.Plug.current_resource(conn)
    activity = Repo.get!(Activity, id)
    channel = "opportunities:" <> to_string(activity.opportunity_id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(activity)

    CercleApi.Endpoint.broadcast!(
      channel, "activity:deleted", %{"activity_id" => id}
    )
    CercleApi.Endpoint.broadcast!("users:" <> to_string(current_user.id),
      "activity:deleted", %{"activity_id" => id}
    )
    send_resp(conn, :no_content, "")
  end

end
