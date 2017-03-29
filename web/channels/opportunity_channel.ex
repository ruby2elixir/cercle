defmodule CercleApi.OpportunityChannel do
  use Phoenix.Channel
  require Logger
  alias CercleApi.{Opportunity, Repo, Contact, TimelineEvent}

  def join("opportunities:" <> opportunity_id, _message, socket) do
    socket = assign(socket, :opportunity_id, opportunity_id)
    {:ok, socket}
  end

  def handle_in("load", _message, socket) do
    opportunity = Opportunity
    |> Opportunity.preload_data
    |> Repo.get(socket.assigns[:opportunity_id])

    data = %{
      opportunity: opportunity,
      activities:  opportunity.activities,
      events: opportunity.timeline_event
    }

    if opportunity do
      opportunity_contacts = CercleApi.Opportunity.contacts(opportunity)

      board = Repo.get!(CercleApi.Board, opportunity.board_id)
      |> Repo.preload(:board_columns)
      data = Map.merge(data,
        %{
          opportunity_contacts: opportunity_contacts,
          board: board,
          board_columns: board.board_columns
        }
      )
    end

    push socket, "load", data

    {:noreply, socket}
  end

end
