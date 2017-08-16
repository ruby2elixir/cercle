defmodule CercleApi.BoardChannel do
  @moduledoc """
  Board Channel.
  """

  use CercleApi.Web, :channel
  alias CercleApi.{Board, Repo, TimelineEvent}

  def join("board:" <> board_id, payload, socket) do
    if authorized?(payload) do
      socket = assign(socket, :board_id, board_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("get", _params, socket) do
    board = Board
    |> Repo.get(socket.assigns[:board_id])

    recent_activities = board
    |> TimelineEvent.recent
    |> Repo.preload([:user, :card])

    push socket, "activities", %{
      recent: CercleApi.APIV2.TimelineEventView.render(
        "recent_list.json",
        timeline_events: recent_activities
      )}

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
