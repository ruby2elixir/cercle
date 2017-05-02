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

  test "create/2 create activity with valid data", state do
    CercleApi.Endpoint.subscribe("users:#{state[:user].id}")

    conn = post state[:conn], "/api/v2/activity",
      activity: %{ "company_id" => 1, "contact_id" => 7,
                   "current_user_time_zone" => "Europe",
                   "due_date" => "2017-04-19T10:45:14.609Z",
                   "opportunity_id" => 59,
                   "title" => "Call"}

    assert_receive %Phoenix.Socket.Broadcast{
      event: "activity:created",
      payload: %{"activity" => _}
    }

    CercleApi.Endpoint.unsubscribe("users:#{state[:user].id}")
    assert json_response(conn, 200) == "{OK: true}"
  end
end
