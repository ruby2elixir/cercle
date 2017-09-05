defmodule CercleApi.APIV2.CardAttachmentView do
  use CercleApi.Web, :view
  alias CercleApi.CardAttachment

  def render("index.json", %{card_attachments: card_attachments}) do
    render_many(card_attachments, __MODULE__, "show.json")
  end

  def render("show.json", %{card_attachment: card_attachment}) do
    CardAttachment.json_data(card_attachment)
  end
end
