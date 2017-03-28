defmodule CercleApi.ContactChannel do
  use Phoenix.Channel
  require Logger

  def join("contacts:" <> _private_subtopic, _message, socket) do
    Logger.debug "> JOIN JOIN"
    {:ok, socket}
  end

end
