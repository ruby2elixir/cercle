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
      opportunities: Enum.map(
        CercleApi.Contact.involved_in_opportunities(contact),
        &opportunity_json(&1)
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
      name: contact.name,
      email: contact.email,
      job_title: contact.job_title,
      phone: contact.phone,
      updated_at: contact.updated_at,
      organization: contact.organization,
      tags: contact.tags
    }
  end

  def opportunity_json(opportunity) do
    %{
      id: opportunity.id,
      name: opportunity.name,
      description: opportunity.description,
      status: opportunity.status,
      contact_ids: opportunity.contact_ids,
      user_id: opportunity.user_id,
      board: opportunity.board,
      board_column: opportunity.board_column
    }
  end
end
