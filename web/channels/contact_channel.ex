defmodule CercleApi.ContactChannel do
  use Phoenix.Channel
  require Logger
  alias CercleApi.{Contact, Repo}

  def join("contacts:" <> contact_id, _message, socket) do
    socket = assign(socket, :contact_id, contact_id)
    Logger.debug "> JOIN JOIN"
    {:ok, socket}
  end

  def handle_in("load_state", _params, socket) do
    contact = Contact
    |> Contact.preload_data
    |> Repo.get(socket.assigns[:contact_id])

    Logger.debug "> LOAD STATE"

    data = %{
      contact: contact,
      company: contact.company,
      company_users: contact.company.users,
      tags: contact.tags,
      organization: contact.organization,
      opportunities: CercleApi.Contact.involved_in_opportunities(contact),
      boards: contact.company.boards
    }

    push socket, "state", data

    {:noreply, socket}
  end

end
