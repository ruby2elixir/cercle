defmodule CercleApi.APIV2.ContactView do
  use CercleApi.Web, :view

  def render("index.json", %{contacts: contacts}) do
    %{data: render_many(contacts, __MODULE__, "contact.json")}
  end

  def render("show.json", %{contact: contact}) do
    %{data: render_one(contact, __MODULE__, "contact.json")}
  end

  def render("full_contact.json", %{contact: contact}) do
    %{
      contact: contact,
      company: contact.company,
      company_users: contact.company.users,
      tags: contact.tags,
      organization: contact.organization,
      cards: Enum.map(
        CercleApi.Contact.involved_in_cards(contact),
        &card_json(&1)
      ),
      boards: contact.company.boards
    }
  end

  #Enum.each(contacts_data, &Repo.insert!(&1))
  def render("contact.json", %{contact: contact}) do
    %{
      id: contact.id,
      company_id: contact.company_id,
      data: contact.data,
      first_name: contact.first_name,
      last_name: contact.last_name,
      email: contact.email,
      job_title: contact.job_title,
      phone: contact.phone,
      updated_at: contact.updated_at,
      organization: contact.organization,
      tags: contact.tags
    }
  end

  def card_json(card) do
    %{
      id: card.id,
      name: card.name,
      description: card.description,
      status: card.status,
      contact_ids: card.contact_ids,
      user_id: card.user_id,
      board: card.board,
      board_column: card.board_column,
      board_id: card.board.id,
      board_column_id: card.board_column.id
    }
  end
end
