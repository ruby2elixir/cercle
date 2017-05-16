defmodule CercleApi.APIV2.CardAttachmentView do
  use CercleApi.Web, :view
  alias CercleApi.CardAttachmentFile

  def render("index.json", %{card_attachments: card_attachments}) do
    render_many(card_attachments, __MODULE__, "show.json")
  end

  def render("show.json", %{card_attachment: card_attachment}) do
    data = %{
      id: card_attachment.id,
      inserted_at: card_attachment.id,
      card_id: card_attachment.inserted_at,
      file_name: card_attachment.attachment.file_name,
      ext_file: Path.extname(card_attachment.attachment.file_name),
      attachment_url: CardAttachmentFile.url({card_attachment.attachment, card_attachment})
    }

    image? = ~w(.jpg .jpeg .gif .png)
    |> Enum.member?(Path.extname(card_attachment.attachment.file_name))
    if image? do
      thumb_url = CardAttachmentFile.url(
        {card_attachment.attachment, card_attachment}, :thumb)

      data = Map.merge(data, %{image: true, thumb_url: thumb_url})
    else
      data = Map.put(data, :image, false)
    end

    data
  end
end
