defmodule CercleApi.APIV2.OpportunityAttachmentView do
  use CercleApi.Web, :view
  alias CercleApi.OpportunityAttachmentFile

  def render("index.json", %{opportunity_attachments: opportunity_attachments}) do
    render_many(opportunity_attachments, __MODULE__, "show.json")
  end

  def render("show.json", %{opportunity_attachment: opportunity_attachment}) do
    data = %{
      id: opportunity_attachment.id,
      inserted_at: opportunity_attachment.id,
      opportunity_id: opportunity_attachment.inserted_at,
      file_name: opportunity_attachment.attachment.file_name,
      ext_file: Path.extname(opportunity_attachment.attachment.file_name),
      attachment_url: OpportunityAttachmentFile.url({opportunity_attachment.attachment, opportunity_attachment})
    }

    image? = ~w(.jpg .jpeg .gif .png)
    |> Enum.member?(Path.extname(opportunity_attachment.attachment.file_name))
    if image? do
      thumb_url = OpportunityAttachmentFile.url(
        {opportunity_attachment.attachment, opportunity_attachment}, :thumb)

      data = Map.merge(data, %{image: true, thumb_url: thumb_url})
    else
      data = Map.put(data, :image, false)
    end

    data
  end
end
