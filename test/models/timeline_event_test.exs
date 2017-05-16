defmodule CercleApi.TimelineEventTest do
  use CercleApi.ModelCase
  import CercleApi.Factory
  alias CercleApi.TimelineEvent

  test "recent/1 return recent events" do
    board = insert(:board)
    card = insert(:card, board: board)
    event_ids = [
      insert(:timeline_event, card: card).id,
      insert(:timeline_event, card: card).id,
      insert(:timeline_event, card: card).id
    ]
    |> Enum.reverse

    assert Enum.map(TimelineEvent.recent(board), fn(v) -> v.id end) == event_ids
  end

end
