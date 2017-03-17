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
    opportunity = Contact.opportunity(contact)

    data = %{
      contact: contact,
      company: contact.company,
      company_users: contact.company.users,
      tags: contact.tags,
      organization: contact.organization,
      activities: contact.activities,
      events: contact.timeline_event,
      opportunity: opportunity,
      opportunities: CercleApi.Contact.involved_in_opportunities(contact),
      boards: contact.company.boards
    }

    if opportunity do
      opportunity_contacts = CercleApi.Opportunity.contacts(opportunity)

      board = Repo.get!(CercleApi.Board, opportunity.board_id)
      |> Repo.preload(:board_columns)
      data = Map.merge(data,
        %{
          opportunity_contacts: opportunity_contacts,
          board: board,
          board_columns: board.board_columns
        }
      )
    end

    push socket, "state", data

    {:noreply, socket}
  end

end
