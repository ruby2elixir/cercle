defmodule CercleApi.CompanyView do
  use CercleApi.Web, :view

  def render("index.json", %{companies: companies}) do
    %{data: render_many(companies, CercleApi.CompanyView, "company.json")}
  end

  def render("show.json", %{company: company}) do
    %{data: render_one(company, CercleApi.CompanyView, "company.json")}
  end

  def render("company.json", %{company: company}) do
    %{id: company.id,
      title: company.title,
      description: company.description}
  end
end
