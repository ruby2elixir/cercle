defmodule CercleApi.CardService do
  @moduledoc """
  Service to handle card events
  """

  use CercleApi.Web, :model
  alias CercleApi.{Repo, Card, Board, Contact, WebhookSubscription}

  def payload_data(card) do
    board = Repo.get(Board, card.board_id)
    %{
      id: card.id,
      name: card.name,
      status: card.status,
      board: %{
        id: board.id,
        name: board.name
      },
      contacts: Enum.map(Card.contacts(card), fn(c) ->
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

  def insert(card) do
    event = "card.created"

    payload = %{
      event: event,
      data: payload_data(card)
    }

    for webhook <- get_subscriptions(card.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end

  def update(card) do
    event = "card.updated"

    payload = %{
      event: event,
      data: payload_data(card)
    }

    ws = get_subscriptions(card.user_id, event)
    for webhook <- get_subscriptions(card.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end

  def delete(card) do
    event = "card.deleted"

    payload = %{
      event: event,
      data: payload_data(card)
    }

    for webhook <- get_subscriptions(card.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end
end
