defmodule CercleApi.APIV2.OpportunityView do
  use CercleApi.Web, :view

  def render("index.json", %{opportunities: opportunities}) do
    %{data: render_many(opportunities, CercleApi.APIV2.OpportunityView, "opportunity.json")}
  end

  def render("show.json", %{opportunity: opportunity}) do
    %{data: render_one(opportunity, CercleApi.APIV2.OpportunityView, "opportunity.json")}
  end

  def render("opportunity.json", %{opportunity: opportunity}) do
    %{id: opportunity.id,
      company_id: opportunity.company_id}
  end
end
