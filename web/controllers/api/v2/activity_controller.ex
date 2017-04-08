defmodule CercleApi.APIV2.ActivityController do

  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{Contact, Activity, Repo}

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "activity" when action in [:create, :update]

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
