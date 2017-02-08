defmodule CercleApi.APIV2.CompanyView do
  use CercleApi.Web, :view

  def render("index.json", %{companies: companies}) do
    %{data: render_many(companies, CercleApi.APIV2.CompanyView, "company.json")}
  end

  def render("show.json", %{company: company}) do
    %{data: render_one(company, CercleApi.APIV2.CompanyView, "company.json")}
  end

  def render("company.json", %{company: company}) do
    %{id: company.id,
      title: company.title,
      admin_email: company.admin_email,
      image_url: CercleApi.Image.url({company.image, company}),
      subtitle1: company.subtitle1,
      description1: company.description1,
      subtitle2: company.subtitle2,
      description2: company.description2,
      reward: company.reward,
      individual: company.individual,
      default_language: company.default_language,
      authentication_required: company.authentication_required}
  end
end
