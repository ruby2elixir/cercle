defmodule CercleApi.APIV2.ActivityController do

  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{User, Activity, Repo}
  alias CercleApi.APIV2.ActivityView, as: ActivityView
  plug CercleApi.Plug.EnsureAuthenticated

  plug :scrub_params, "activity" when action in [:create, :update]

  def index(conn, params) do
    current_user = params["user_id"] && Repo.get(User, params["user_id"])
    if current_user do
      company = current_company(conn)
      query = Activity
      |> Activity.by_user(current_user.id)
      |> Activity.by_company(company.id)
    else
      query = Activity
    end

    query = query
    |> Activity.order_by_date(:asc)
    |> Activity.by_status(params["is_done"] || false)

    if params["start_in"] do
      query = Activity.start_in(query, params["start_in"])
    end

    if params["overdue"] do
      query = Activity.by_date(query, :overdue)
    end

    query_params = %{
      "paginate" => %{"per_page" => Map.get(params, "per_page", "50"),
                      "page" => Map.get(params, "page", "1")}
    }

    {queryable, _} = query |> Rummage.Ecto.rummage(query_params)

    activities = queryable
    |> Repo.all
    |> Repo.preload([:user, :card])
    render(conn, "list.json", activities: activities)
  end

  def create(conn, %{"activity" => activity_params}) do
    current_user = CercleApi.Plug.current_user(conn)
    changeset = Activity.changeset(%Activity{}, activity_params)

    case Repo.insert(changeset) do
      {:ok, activity} ->
        activity = activity
        |> Repo.preload([:user, :card])
        CercleApi.ActivityService.add(activity)
        activity_json = %{"activity" => ActivityView.activity_json(activity)}
        CercleApi.Endpoint.broadcast!(
          "cards:" <> to_string(activity.card_id),
          "activity:created", activity_json
        )

        CercleApi.Endpoint.broadcast!(
          "users:" <> to_string(current_user.id),
          "activity:created", activity_json
        )
        render(conn, "show.json", activity: activity)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "activity" => activity_params}) do
    current_user = CercleApi.Plug.current_user(conn)
    activity = Activity
    |> Repo.get!(id)
    |> Repo.preload([:user, :card])

    changeset = Activity.changeset(activity, activity_params)

    case Repo.update(changeset) do
      {:ok, _activity} ->
        activity = Activity
        |> Repo.get!(id)
        |> Repo.preload([:user, :card])
        activity_json = %{"activity" => ActivityView.activity_json(activity)}
        CercleApi.ActivityService.add(activity)
        CercleApi.Endpoint.broadcast!(
          "cards:" <> to_string(activity.card_id),
          "activity:updated", activity_json
        )

        CercleApi.Endpoint.broadcast!(
          "users:" <> to_string(current_user.id),
          "activity:updated", activity_json
        )
        render(conn, "show.json", activity: activity)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    current_user = CercleApi.Plug.current_user(conn)
    activity = Repo.get!(Activity, id)
    channel = "cards:" <> to_string(activity.card_id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(activity)
    CercleApi.ActivityService.delete("activity", id)
    CercleApi.Endpoint.broadcast!(
      channel, "activity:deleted", %{"activity_id" => id}
    )
    CercleApi.Endpoint.broadcast!("users:" <> to_string(current_user.id),
      "activity:deleted", %{"activity_id" => id}
    )
    send_resp(conn, :no_content, "")
  end

end
