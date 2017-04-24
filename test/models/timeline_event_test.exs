defmodule CercleApi.TimelineEventTest do
  use CercleApi.ModelCase
  import CercleApi.Factory
  alias CercleApi.TimelineEvent
  test "recent/1 return recent events" do
    user = insert(:user)
    board = insert(:board, company: user.company)
    event_ids = [
      insert(:timeline_event, company: user.company).id,
      insert(:timeline_event, company: user.company).id,
      insert(:timeline_event, company: user.company).id
    ]
    |> Enum.reverse

    assert Enum.map(TimelineEvent.recent(board), fn(v) -> v.id end) == event_ids
  end

end
