defmodule CercleApi.APIV2.OrganizationView do
  use CercleApi.Web, :view

  def render("index.json", %{organizations: organizations}) do
    %{data: render_many(organizations, CercleApi.APIV2.OrganizationView, "organization.json")}
  end

  def render("show.json", %{organization: organization}) do
    %{data: render_one(organization, CercleApi.APIV2.OrganizationView, "organization.json")}
  end

  def render("organization.json", %{organization: organization}) do
    %{id: organization.id}
  end
end
