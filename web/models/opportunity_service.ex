defmodule CercleApi.OpportunityService do
  @moduledoc """
  Service to handle opportunity events
  """

  use CercleApi.Web, :model
  alias CercleApi.{Repo, Opportunity, Board, Contact, WebhookSubscription}

  def payload_data(opportunity) do
    board = Repo.get(Board, opportunity.board_id)
    %{
      id: opportunity.id,
      name: opportunity.name,
      status: opportunity.status,
      board: %{
        id: board.id,
        name: board.name
      },
      contacts: Enum.map(Opportunity.contacts(opportunity), fn(c) ->
        %{
          id: c.id,
          name: c.name
      }end)
    }
  end

  def get_subscriptions(user_id, event) do
    query = from p in WebhookSubscription,
      where: p.user_id == ^user_id,
      where: p.event == ^event
    webhook_subscriptions = query
    |> Repo.all
  end

  def insert(opportunity) do
    event = "opportunity.created"

    payload = %{
      event: event,
      data: payload_data(opportunity)
    }

    for webhook <- get_subscriptions(opportunity.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end

  def update(opportunity) do
    event = "opportunity.updated"

    payload = %{
      event: event,
      data: payload_data(opportunity)
    }

    ws = get_subscriptions(opportunity.user_id, event)
    for webhook <- get_subscriptions(opportunity.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end

  def delete(opportunity) do
    event = "opportunity.deleted"

    payload = %{
      event: event,
      data: payload_data(opportunity)
    }

    for webhook <- get_subscriptions(opportunity.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end
end
