defmodule CercleApi.APIV2.ActivityView do
  use CercleApi.Web, :view

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
end
