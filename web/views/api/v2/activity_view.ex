defmodule CercleApi.APIV2.ActivityView do
  use CercleApi.Web, :view

  def render("list.json", %{activities: activities}) do
    %{activities: Enum.map(activities, &activity_json/1)}
  end

  def render("index.json", %{activities: activities}) do
    %{data: render_many(activities, CercleApi.APIV2.ActivityView, "activity.json")}
  end

  def render("show.json", %{activity: activity}) do
    %{data: render_one(activity, CercleApi.APIV2.ActivityView, "activity.json")}
  end

  def render("activity.json", %{activity: activity}) do
    activity_json(activity)
  end

  def activity_json(activity) do
    due_date_with_tz =
      case activity.due_date do
        nil -> nil
        due_date ->
          "#{Ecto.DateTime.to_iso8601(due_date)}Z"
          |> Timex.parse!("{ISO:Extended}")
          |> Timex.Timezone.convert(activity.user.time_zone)
      end

    %{
      id: activity.id,
      title: activity.title,
      is_done: activity.is_done,
      due_date: activity.due_date,
      due_date_with_current_timezone: due_date_with_tz,
      company_id: activity.company_id,
      contact_id: activity.contact_id,
      user_id: activity.user_id,
      card_id: activity.card_id,
      user: activity.user,
      contact: activity.contact
    }
  end
end
