defmodule CercleApi.BoardChannelTest do
  use CercleApi.ChannelCase
  import CercleApi.Factory
  alias CercleApi.{BoardChannel, TimelineEvent}

  setup do
    board = insert(:board)
    {:ok, _, socket} =
      socket("board_id", %{board_id: board.id})
      |> subscribe_and_join(BoardChannel, "board:#{board.id}")

    {:ok, socket: socket, board: board}
  end

  test "handle_in/get", state do
    insert(:timeline_event, company: state[:board].company)
    insert(:timeline_event, company: state[:board].company)
    insert(:timeline_event, company: state[:board].company)

    timeline_events = TimelineEvent
    |> Repo.all
    |> Repo.preload([:user, opportunity: :main_contact])
    events = CercleApi.APIV2.TimelineEventView.render("recent_list.json",
      timeline_events: timeline_events
    )
    push state[:socket], "get", %{}
    assert_push "activities", %{ recent: events }
  end
end
