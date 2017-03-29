defmodule CercleApi.APIV2.TimelineEventView do
  use CercleApi.Web, :view

  def render("index.json", %{timeline_events: timeline_events}) do
    %{data: render_many(timeline_events, CercleApi.APIV2.TimelineEventView, "timeline_event.json")}
  end

  def render("show.json", %{timeline_event: timeline_event}) do
    %{data: render_one(timeline_event, CercleApi.APIV2.TimelineEventView, "timeline_event.json")}
  end

  def render("timeline_event.json", %{timeline_event: timeline_event}) do
    %{id: timeline_event.id,
      event_name: timeline_event.event_name,
      opportunity_id: timeline_event.opportunity_id,
      contact_id: timeline_event.contact_id,
      content: timeline_event.content}
  end
end
