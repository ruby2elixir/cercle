defmodule CercleApi.CardChannel do
  @moduledoc """
  Card Channel.
  """
  use Phoenix.Channel
  require Logger
  alias CercleApi.{Card, Repo, Contact, TimelineEvent}

  def join("cards:" <> card_id, _message, socket) do
    socket = assign(socket, :card_id, card_id)
    {:ok, socket}
  end

  def handle_in("load", _message, socket) do
    card = Card
    |> Card.preload_data
    |> Repo.get(socket.assigns[:card_id])

    data = %{
      card: card,
      activities:  card.activities,
      events: card.timeline_event
    }

    if card do
      card_contacts = CercleApi.Card.contacts(card)

      board = CercleApi.Board
      |> Repo.get!(card.board_id)
      |> Repo.preload(:board_columns)
      data = Map.merge(data,
        %{
          card_contacts: card_contacts,
          board: board,
          board_columns: board.board_columns
        }
      )
    end

    push socket, "load", data

    {:noreply, socket}
  end

end
