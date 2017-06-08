defmodule CercleApi.APIV2.WebhookSubscriptionController do
  use CercleApi.Web, :controller

  alias CercleApi.WebhookSubscription
  alias CercleApi.User

  plug CercleApi.Plug.EnsureAuthenticated

  require Logger

  def index(conn, _params) do
    current_user = CercleApi.Plug.current_user(conn)
    query = from p in WebhookSubscription,
      where: p.user_id == ^current_user.id,
      order_by: [desc: p.event]

    webhook_subscriptions = query
    |> Repo.all

    render(conn, "index.json", webhook_subscriptions: webhook_subscriptions)
  end

  def create(conn, %{"webhook_subscription" => webhook_subscription_params}) do
    current_user = CercleApi.Plug.current_user(conn)
    webhook_subscription = Repo.get_by(WebhookSubscription, event: webhook_subscription_params["event"], user_id: current_user.id)

    if webhook_subscription do
      changeset = WebhookSubscription.changeset(webhook_subscription, webhook_subscription_params)
      op = Repo.update(changeset)
    else
      changeset = current_user
        |> Ecto.build_assoc(:webhook_subscriptions)
        |> WebhookSubscription.changeset(webhook_subscription_params)
      op = Repo.insert(changeset)
    end

    case op do
      {:ok, webhook_subscription} ->
        conn
        |> put_status(:created)
        |> render("show.json", webhook_subscription: webhook_subscription)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => event}) do
    current_user = CercleApi.Plug.current_user(conn)
    webhook_subscription = Repo.get_by(WebhookSubscription, event: event, user_id: current_user.id)
    Repo.delete!(webhook_subscription)
    json conn, %{status: 200}
  end
end
