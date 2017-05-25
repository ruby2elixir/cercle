defmodule CercleApi.APIV2.ActivityControllerTest do
  use CercleApi.ConnCase
  use Timex
  import CercleApi.Factory

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: user.company}
  end

  test "index/2 responds with all Activities", state do
    activity = insert(:activity,
      user: state[:user], company: state[:company], due_date: Timex.now()
    )
    conn = get state[:conn], "/api/v2/activity", user_id: state[:user].id
    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.ActivityView, "list.json",
      %{
        activities: [activity]
      }
    )
  end
  test "index/2 responds with start_in 15 minutes activities", state do
    activity = insert(:activity, is_done: false, due_date: Timex.shift(Timex.now(), minutes: 10))
    insert(:activity, is_done: false, due_date: Timex.shift(Timex.now(), minutes: 120))

    conn = get state[:conn], "/api/v2/activity", start_in: 15
    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.ActivityView, "list.json",
      %{ activities: [activity] }
    )
  end

  test "index/2 responds with overdue", state do
    activity = insert(:activity, is_done: false, due_date: Timex.shift(Timex.now(), days: -2))
    activity1 = insert(:activity, is_done: false, due_date: Timex.shift(Timex.now(), days: -12))

    conn = get state[:conn], "/api/v2/activity", overdue: true
    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.ActivityView, "list.json",
      %{
        activities: [activity1, activity]
      }
    )
  end

  test "index/2 responds with all done activities", state do
    activity = insert(:activity, is_done: true)
    insert(:activity, is_done: false)

    conn = get state[:conn], "/api/v2/activity", is_done: true
    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.ActivityView, "list.json",
      %{ activities: [activity] }
    )
  end

  test "index/2 responds without all done activities", state do
    insert(:activity, is_done: true)
    activity1 = insert(:activity, is_done: false)

    conn = get state[:conn], "/api/v2/activity", is_done: false
    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.ActivityView, "list.json",
      %{ activities: [activity1] }
    )
  end

  test "create/2 create activity with valid data", state do
    CercleApi.Endpoint.subscribe("users:#{state[:user].id}")

    conn = post state[:conn], "/api/v2/activity",
      activity: %{ "company_id" => 1, "contact_id" => 7,
                   "current_user_time_zone" => "Europe",
                   "due_date" => "2017-04-19T10:45:14.609Z",
                   "card_id" => 59,
                   "title" => "Call"}

    assert_receive %Phoenix.Socket.Broadcast{
      event: "activity:created",
      payload: %{"activity" => _}
    }

    CercleApi.Endpoint.unsubscribe("users:#{state[:user].id}")
    assert json_response(conn, 200) == "{OK: true}"
  end
end
