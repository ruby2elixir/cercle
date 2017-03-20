defmodule CercleApi.APIV2.ActivityController do

  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{Contact, Activity, Organization, User, Company}

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "activity" when action in [:create, :update]

  def create(conn, %{"activity" => activity_params}) do
   changeset = Activity.changeset(%Activity{}, activity_params)
    case Repo.insert(changeset) do
      {:ok, activity} ->
        activity_reload = Repo.preload(Repo.get!(CercleApi.Activity, activity.id), [:user])
        company = Repo.preload(Repo.get!(CercleApi.Company, activity_reload.user.company_id), [:users])
        html = Phoenix.View.render_to_string(
          CercleApi.ContactView, "_task.html",
          id: activity.id, is_done: activity.is_done,
          title: activity.title, due_date: activity.due_date,
          user_name: activity_reload.user.user_name,
          user_id: activity_reload.user_id, company: company,
          current_user_time_zone: activity_params["current_user_time_zone"]
        )
        channel = "contacts:"  <> to_string(activity.contact_id)
        CercleApi.Endpoint.broadcast!(channel, "new:activity", %{"html" => html})
        CercleApi.Endpoint.broadcast!(
          channel, "activity:created", %{"activity" => activity_reload}
        )
        json conn, "{OK: true}"
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "activity" => activity_params}) do
    activity = Repo.get!(Activity, id) |> Repo.preload(:user)

    changeset = Activity.changeset(activity, activity_params)

    case Repo.update(changeset) do
      {:ok, activity} ->
        channel = "contacts:"  <> to_string(activity.contact_id)
        CercleApi.Endpoint.broadcast!(
          channel, "activity:updated", %{"activity" => activity}
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
    channel = "contacts:"  <> to_string(activity.contact_id)
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(activity)

    CercleApi.Endpoint.broadcast!(
      channel, "activity:deleted", %{"activity_id" => id}
    )
    send_resp(conn, :no_content, "")
  end

end
