defmodule CercleApi.ContactChannel do
  use Phoenix.Channel
  require Logger
  alias CercleApi.{Contact, Repo}

  def join("contacts:" <> contact_id, _message, socket) do
    socket = assign(socket, :contact_id, contact_id)
    Logger.debug "> JOIN JOIN"
    {:ok, socket}
  end

end
