defmodule CercleApi.CardAttachment do
  @moduledoc """
  Card attachments
  """

  use CercleApi.Web, :model
  use Arc.Ecto.Schema

  schema "card_attachments" do
    field :attachment, CercleApi.CardAttachmentFile.Type
    belongs_to :card, CercleApi.Card

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:card_id])
    |> cast_attachments(params, [:attachment])
    |> validate_required([:card_id])
  end
end

defimpl Poison.Encoder, for: CercleApi.CardAttachment do
  def encode(model, options) do
    image = ~w(.jpg .jpeg .gif .png)
    |> Enum.member?(Path.extname(model.attachment.file_name))

    attachment_url = CercleApi.CardAttachmentFile.url({model.attachment, model})

    data = model
    |> Map.take([:id, :card_id, :inserted_at])
    |> Map.put(:attachment_url, attachment_url)
    |> Map.put(:file_name, model.attachment.file_name)
    |> Map.put(:ext_file, Path.extname(model.attachment.file_name))

    if image do
      thumb_url = CercleApi.CardAttachmentFile.url({model.attachment, model}, :thumb)
      data = Map.merge(data, %{image: true, thumb_url: thumb_url})
    else
      data = Map.put(data, :image, false)
    end

    Poison.Encoder.encode(data, options)
  end
end

defimpl Poison.Encoder, for: CercleApi.CardAttachment do
  def encode(model, options) do
    model
    |> Map.take([:id])
    |> Map.put(:attachment_url, CercleApi.CardAttachmentFile.url({model.attachment, model}))
    |> Poison.Encoder.encode(options)
  end
end
