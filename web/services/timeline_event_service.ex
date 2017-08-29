defmodule CercleApi.TimelineEventService do
  @moduledoc """
  Service to handle timeline events
  """

  use CercleApi.Web, :service

  alias CercleApi.{TimelineEvent}

  def create(event) do
    with event <- Repo.preload(event, [:user, :card]) do
      CercleApi.Endpoint.broadcast!(
        "cards:"  <> to_string(event.card_id),
        "timeline_event:created", %{"event" => event}
      )
      CercleApi.Endpoint.broadcast!(
        "board:" <> to_string(event.card.board_id),
        "timeline_event:created",
        CercleApi.APIV2.TimelineEventView.render(
          "recent_item.json", timeline_event: event)
      )
    end
  end

  def update(event) do
    with event <- Repo.preload(event, [:user, :card]) do
      CercleApi.Endpoint.broadcast!(
        "cards:"  <> to_string(event.card_id),
        "timeline_event:updated", %{"event" => event}
      )
      CercleApi.Endpoint.broadcast!(
        "board:" <> to_string(event.card.board_id),
        "timeline_event:updated",
        CercleApi.APIV2.TimelineEventView.render(
          "recent_item.json", timeline_event: event)
      )
    end
  end

  def delete(event) do
    with event <- Repo.preload(event, [:user, :card]) do
      CercleApi.Endpoint.broadcast!(
        "cards:"  <> to_string(event.card_id),
        "timeline_event:deleted", %{"id" => event.id}
      )
      CercleApi.Endpoint.broadcast!(
        "board:" <> to_string(event.card.board_id),
        "timeline_event:deleted", %{"id" => event.id}
      )
    end
  end
end
