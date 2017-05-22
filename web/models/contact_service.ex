defmodule CercleApi.ContactService do
  @moduledoc """
  Service to handle contact events
  """

  use CercleApi.Web, :model
  alias CercleApi.{Repo, Contact, WebhookSubscription}

  def payload_data(contact) do
    %{
      id: contact.id,
      first_name: contact.first_name,
      last_name: contact.last_name,
      phone: contact.phone,
      email: contact.email,
      description: contact.description,
      job_title: contact.job_title
    }
  end

  def get_subscriptions(user_id, event) do
    query = from p in WebhookSubscription,
      where: p.user_id == ^user_id,
      where: p.event == ^event
    webhook_subscriptions = query
    |> Repo.all
  end

  def insert(contact) do
    event = "contact.created"

    payload = %{
      event: event,
      data: payload_data(contact)
    }

    for webhook <- get_subscriptions(contact.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end

  def update(contact) do
    event = "contact.updated"

    payload = %{
      event: event,
      data: payload_data(contact)
    }

    ws = get_subscriptions(contact.user_id, event)
    for webhook <- get_subscriptions(contact.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end

  def delete(contact) do
    event = "contact.deleted"

    payload = %{
      event: event,
      data: payload_data(contact)
    }

    for webhook <- get_subscriptions(contact.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end
end
