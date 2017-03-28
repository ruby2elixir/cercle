defmodule CercleApi.TimelineEventChannel do
  use CercleApi.Web, :channel
  require Logger
  alias CercleApi.{Contact, Repo}

  def join("timeline_event:" <> contact_id, payload, socket) do
    socket = assign(socket, :contact_id, contact_id)
    {:ok, socket}
  end

  # def handle_in("event:create", payload, socket) do

  #   {:reply, {:ok, payload}, socket}
  # end
end
