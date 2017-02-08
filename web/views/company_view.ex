defmodule CercleApi.CompanyView do
  use CercleApi.Web, :view

  def render("code_already_used.json", %{code: code}) do
    %{alert: "error", message: "Code already used"}
  end

  def render("index.json", %{companies: companies}) do
    %{data: render_many(companies, CercleApi.CompanyView, "company.json")}
  end

  def render("show.json", %{company: company}) do
    %{data: render_one(company, CercleApi.CompanyView, "company.json")}
  end

  def render("company.json", %{company: company}) do
    %{id: company.id,
      title: company.title,
      admin_email: company.admin_email,
      image_url: CercleApi.Image.url({company.image, company}),
      token: company.app_secret_key,
      subtitle1: company.subtitle1,
      description1: company.description1,
      subtitle2: company.subtitle2,
      description2: company.description2,
      reward: company.reward,
      individual: company.individual}
  end
end
