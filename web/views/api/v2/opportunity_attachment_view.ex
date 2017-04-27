defmodule CercleApi.APIV2.OpportunityAttachmentView do
  use CercleApi.Web, :view

  def render("index.json", %{opportunity_attachments: opportunity_attachments}) do
    render_many(opportunity_attachments, __MODULE__, "show.json")
  end

  def render("show.json", %{opportunity_attachment: opportunity_attachment}) do
    %{
      id: opportunity_attachment.id,
      opportunity_id: opportunity_attachment.opportunity_id,
      url: CercleApi.OpportunityAttachmentFile.url({
        opportunity_attachment.attachment, opportunity_attachment
          })
    }
  end
end
