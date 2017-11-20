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
      contact: render_one(contact, __MODULE__, "contact.json"),
      company: contact.company,
      company_users: contact.company.users,
      tags: contact.tags,
      organization: contact.organization,
      cards: Enum.map(
        CercleApi.Contact.involved_in_cards(contact),
        &CercleApi.APIV2.CardView.card_json(&1)
      ),
      boards: contact.company.boards
    }
  end

  def render("contact.json", %{contact: contact}) do
    %{
      id: contact.id,
      company_id: contact.company_id,
      data: contact.data,
      first_name: contact.first_name,
      last_name: contact.last_name,
      name: String.trim(Enum.join([contact.first_name, contact.last_name], " ")),
      email: contact.email,
      job_title: contact.job_title,
      phone: contact.phone,
      updated_at: contact.updated_at,
      organization: contact.organization,
      tags: contact.tags,
      description: contact.description
    }
  end
end
