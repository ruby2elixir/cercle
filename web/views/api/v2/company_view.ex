defmodule CercleApi.APIV2.CompanyView do
  use CercleApi.Web, :view
  alias CercleApi.CompanyLogoImage

  def render("index.json", %{companies: companies}) do
    %{data: render_many(companies, CercleApi.APIV2.CompanyView, "company.json")}
  end

  def render("show.json", %{company: company}) do
    %{data: render_one(company, CercleApi.APIV2.CompanyView, "company.json")}
  end

  def render("users.json", %{company: company}) do
    users = company.users
    %{users: render_many(users, CercleApi.APIV2.UserView, "user.json")}
  end

  def render("company.json", %{company: company}) do
    %{
      id: company.id,
      title: company.title,
      logo: CompanyLogoImage.url({company.logo_image, company}, :small)
    }
  end

end
