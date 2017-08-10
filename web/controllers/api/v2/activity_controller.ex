defmodule CercleApi.APIV2.ActivityController do

  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{User, Activity, Repo}

  plug CercleApi.Plug.EnsureAuthenticated

  plug :scrub_params, "activity" when action in [:create, :update]

  def index(conn, params) do
    current_user = params["user_id"] && Repo.get(User, params["user_id"])
    if current_user do
      query = Activity
      |> Activity.by_user(current_user.id)
      |> Activity.by_company(current_user.company_id)
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
    |> Repo.preload([:user])
    render(conn, "list.json", activities: activities)
  end

  def create(conn, %{"activity" => activity_params}) do
    current_user = CercleApi.Plug.current_user(conn)
    changeset = current_user
    |> build_assoc(:activities)
    |> Activity.changeset(activity_params)

    case Repo.insert(changeset) do
      {:ok, activity} ->
        activity = activity
        |> Repo.preload([:user])
        CercleApi.ActivityService.add(activity)
        CercleApi.Endpoint.broadcast!(
          "cards:" <> to_string(activity.card_id),
          "activity:created", %{"activity" => activity}
        )

        CercleApi.Endpoint.broadcast!(
          "users:" <> to_string(current_user.id),
          "activity:created", %{"activity" => activity}
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
    |> Repo.preload(:user)

    changeset = Activity.changeset(activity, activity_params)

    case Repo.update(changeset) do
      {:ok, activity} ->
        activity = activity
        |> Repo.preload([:user])
        CercleApi.ActivityService.add(activity)
        CercleApi.Endpoint.broadcast!(
          "cards:" <> to_string(activity.card_id),
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
    current_user = CercleApi.Plug.current_user(conn)
    activity = Repo.get!(Activity, id)
    channel = "cards:" <> to_string(activity.card_id)

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
