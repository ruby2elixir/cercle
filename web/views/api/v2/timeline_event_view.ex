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
      card_id: timeline_event.card_id,
      contact_id: timeline_event.contact_id,
      content: timeline_event.content}
  end

  def render("recent_list.json",  %{timeline_events: timeline_events}) do
    render_many(
      timeline_events, CercleApi.APIV2.TimelineEventView, "recent_item.json"
    )
  end

  def render("recent_item.json",  %{timeline_event: timeline_event}) do
    if timeline_event.user do
      profile_url = CercleApi.UserProfileImage.url({
        timeline_event.user.profile_image, timeline_event.user}, :small
      )
      user_name = timeline_event.user.user_name
    else
      profile_url = ""
      user_name = ""
    end

    %{
      id: timeline_event.id,
      profile_image_url: profile_url,
      event_name: timeline_event.event_name,
      card_id: timeline_event.card_id,
      contact_id: timeline_event.contact_id,
      content: timeline_event.content,
      user_name: user_name,
      main_contact_name: main_contact_name(timeline_event),
      created_at: timeline_event.inserted_at
    }
  end

  defp main_contact_name(event) do
    (event && event.card &&
      event.card.main_contact &&
      Enum.join([event.card.main_contact.first_name, event.card.main_contact.last_name], " ")) || ""
  end
end
