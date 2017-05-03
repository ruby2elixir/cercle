defmodule CercleApi.APIV2.ActivityController do

  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{User, Activity, Repo}

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "activity" when action in [:create, :update]

  def index(conn, params) do
    current_user = Repo.get(User, Map.get(params, "user_id"))
    if current_user do
      query = Activity
      |> Activity.by_user(current_user.id)
      |> Activity.by_company(current_user.company_id)
      |> Activity.order_by_date
    else
      query = Activity.order_by_date
    end

    if params["start_in"] do
      query = query
      |> Activity.start_in(params["start_in"])
    end

    query_params = %{
      "search" => %{"is_done" => %{"assoc" => [], "search_term" => Map.get(params, "is_done", false)}},
      "paginate" => %{"per_page" => Map.get(params, "per_page", "50"),
                      "page" => Map.get(params, "page", "1")}
    }
    {queryable, _} = query |> Rummage.Ecto.rummage(query_params)

    activities = queryable
    |> Repo.all
    |> Repo.preload([:contact, :user])
    render(conn, "list.json", activities: activities)
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
