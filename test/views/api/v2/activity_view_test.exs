defmodule CercleApi.APIV2.ActivityViewTest do
  use CercleApi.ConnCase, async: true
  import CercleApi.Factory
  alias CercleApi.APIV2.ActivityView
  use Timex

  test "list.json" do
    user = insert(:user)
    company = insert(:company)
    today_activity = insert(:activity,
      user: user, company: company, due_date: Timex.now()
    )

    later_activity = insert(:activity,
      user: user, company: company,
      due_date: Timex.shift(DateTime.utc_now(), days: 2)
    )

    overdue_activity = insert(:activity,
      user: user, company: company,
      due_date: Timex.shift(DateTime.utc_now(), days: -10)
    )

    rendered_activities = ActivityView.render("list.json",
      %{
        activities_today: [today_activity],
        activities_overdue: [overdue_activity],
        activities_later: [later_activity]
      })

    assert rendered_activities == %{
      activities: %{
        today: [ActivityView.activity_json(today_activity)],
        overdue: [ActivityView.activity_json(overdue_activity)],
        later: [ActivityView.activity_json(later_activity)],
      }
    }
  end
end
