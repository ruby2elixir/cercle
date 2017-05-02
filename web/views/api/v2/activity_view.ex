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
    %{id: activity.id,
      user_id: activity.user_id,
      title: activity.title}
  end

  def activity_json(activity) do
    %{
      id: activity.id,
      title: activity.title,
      is_done: activity.is_done,
      due_date: activity.due_date,
      company_id: activity.company_id,
      contact_id: activity.contact_id,
      user_id: activity.user_id,
      opportunity_id: activity.opportunity_id,
      user: activity.user,
      contact: activity.contact
    }
  end
end
