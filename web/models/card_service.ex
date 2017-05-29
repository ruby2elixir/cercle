defmodule CercleApi.CardService do
  @moduledoc """
  Service to handle card events
  """

  use CercleApi.Web, :model
  alias CercleApi.{Repo, Card, Board, Contact, WebhookSubscription, TimelineEvent}

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
          first_name: c.first_name,
          last_name: c.last_name
      }end)
    }
  end

  def event_payload(card, data \\ %{}) do
    with card <- Repo.preload(card, [:board, :board_column]),
           do: Map.merge(data,
                 %{
                   id: card.id,
                   name: card.name,
                   status: card.status,
                   board: %{ id: card.board.id, name: card.board.name },
                   board_column: %{ id: card.board_column.id, name: card.board_column.name },
                   contacts: Enum.map(Card.contacts(card), fn(c) ->
                     %{ id: c.id, first_name: c.first_name, last_name: c.last_name }
                   end)
                 })
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

    event_changeset = %TimelineEvent{}
    |> TimelineEvent.changeset(
      %{ event_name: event, card_id: card.id, content: event,
         user_id: card.user_id, company_id: card.company_id,
         metadata: event_payload(card, %{ action: :create_card })
      }
    )

    with {:ok, tm_event} <- Repo.insert(event_changeset),
         {event} <- Repo.preload(tm_event, [:card, :user]),
      do: CercleApi.TimelineEventService.create(tm_event)


    for webhook <- get_subscriptions(card.user_id, event) do
      HTTPoison.post(webhook.url, Poison.encode!(payload), [{"Content-Type", "application/json"}])
    end
  end

  def update(card, changes \\ %{}) do
    event = "card.updated"

    payload = %{
      event: event,
      data: payload_data(card)
    }

    event_changeset = %TimelineEvent{}
    |> TimelineEvent.changeset(
      %{ event_name: event, card_id: card.id, content: event,
         user_id: card.user_id, company_id: card.company_id,
         metadata: event_payload(card, %{ action: :update_card, changes: changes })
      }
    )

    with {:ok, tm_event} <- Repo.insert(event_changeset),
         {event} <- Repo.preload(tm_event, [:card, :user]),
      do: CercleApi.TimelineEventService.update(tm_event)


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
