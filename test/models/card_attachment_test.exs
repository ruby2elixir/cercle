defmodule CercleApi.CardAttachmentTest do
  use CercleApi.ModelCase
  import CercleApi.Factory
  alias CercleApi.{ CardAttachment, CardAttachmentFile }

  @invalid_attrs %{}

  test "changeset with invalid attributes" do
    changeset = CardAttachment.changeset(%CardAttachment{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "json_data" do
    user = insert(:user)
    card = insert(:card, user: user)

    attach = CardAttachment
    |> attach_file(insert(:card_attachment, card: card),
    :attachment, "test/fixtures/logo.png")

    assert CardAttachment.json_data(attach) == %{
      attachment_url: CardAttachmentFile.url({attach.attachment, attach}),
      card_id: card.id, ext_file: ".png", file_name: "logo.png", id: attach.id,
      image: true, inserted_at: attach.inserted_at,
      thumb_url: CardAttachmentFile.url({attach.attachment, attach}, :thumb)
    }
  end
end
