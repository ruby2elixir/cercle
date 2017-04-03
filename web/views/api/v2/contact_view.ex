defmodule CercleApi.APIV2.ContactView do
  use CercleApi.Web, :view

  def render("index.json", %{contacts: contacts}) do
    %{data: render_many(contacts, CercleApi.APIV2.ContactView, "contact.json")}
  end

  def render("show.json", %{contact: contact}) do
    %{data: render_one(contact, CercleApi.APIV2.ContactView, "contact.json")}
  end

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

end
