defmodule CercleApi.APIV2.WebhookSubscriptionView do
  use CercleApi.Web, :view

  def render("index.json", %{webhook_subscriptions: webhook_subscriptions}) do
    %{data: render_many(webhook_subscriptions, CercleApi.APIV2.WebhookSubscriptionView, "webhook_subscription.json")}
  end

  def render("show.json", %{webhook_subscription: webhook_subscription}) do
    %{data: render_one(webhook_subscription, CercleApi.APIV2.WebhookSubscriptionView, "webhook_subscription.json")}
  end

  def render("webhook_subscription.json", %{webhook_subscription: webhook_subscription}) do
    %{id: webhook_subscription.id,
      event: webhook_subscription.event,
      url: webhook_subscription.url}
  end
end
