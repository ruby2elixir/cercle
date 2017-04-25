defmodule CercleApi.TimelineEventTest do
  use CercleApi.ModelCase
  import CercleApi.Factory
  alias CercleApi.TimelineEvent

  test "recent/1 return recent events" do
    board = insert(:board)
    opportunity = insert(:opportunity, board: board)
    event_ids = [
      insert(:timeline_event, opportunity: opportunity).id,
      insert(:timeline_event, opportunity: opportunity).id,
      insert(:timeline_event, opportunity: opportunity).id
    ]
    |> Enum.reverse

    assert Enum.map(TimelineEvent.recent(board), fn(v) -> v.id end) == event_ids
  end

end
