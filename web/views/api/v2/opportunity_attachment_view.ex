defmodule CercleApi.APIV2.OpportunityAttachmentView do
  use CercleApi.Web, :view

  def render("index.json", %{attachments: attachments}) do
    %{data: render_many(attachments, __MODULE__, "attachment.json")}
  end

  def render("attachment.json", %{attachment: attachment}) do
    %{
      id: attachment.id,
      opportunity_id: attachment.opportunity_id
    }
  end
end
