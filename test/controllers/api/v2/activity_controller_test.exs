defmodule CercleApi.APIV2.ActivityControllerTest do
  use CercleApi.ConnCase
  use Timex
  import CercleApi.Factory
  alias CercleApi.{Activity}

  setup %{conn: conn} do
    user = insert(:user)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: user.company}
  end

  test "index/2 responds with all Activities", state do
    today_activity = insert(:activity,
      user: state[:user], company: state[:company], due_date: Timex.now()
    )

    later_activity = insert(:activity,
      user: state[:user], company: state[:company],
      due_date: Timex.shift(DateTime.utc_now(), days: 2)
    )

    overdue_activity = insert(:activity,
      user: state[:user], company: state[:company],
      due_date: Timex.shift(DateTime.utc_now(), days: -10)
    )
    conn = get state[:conn], "/api/v2/activity"
    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.ActivityView, "list.json",
      %{
        activities_today: [today_activity],
        activities_overdue: [overdue_activity],
        activities_later: [later_activity],
      }
    )
  end
end
