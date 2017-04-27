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

  def render("full_opportunity.json",
    %{opportunity: opportunity,
      opportunity_contacts: opportunity_contacts,
      board: board, attachments: attachments }) do
    %{
      opportunity: opportunity,
      activities:  opportunity.activities,
      events: opportunity.timeline_event,
      opportunity_contacts: opportunity_contacts,
      board: board,
      board_columns: board.board_columns,
      attachments: attachments
      }
  end
end
