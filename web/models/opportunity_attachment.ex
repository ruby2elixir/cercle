defmodule CercleApi.OpportunityAttachment do
  @moduledoc """
  Opportunity attachments
  """

  use CercleApi.Web, :model
  use Arc.Ecto.Schema

  schema "opportunity_attachments" do
    field :attachment, CercleApi.OpportunityAttachmentFile.Type
    belongs_to :opportunity, CercleApi.Opportunity

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:opportunity_id])
    |> cast_attachments(params, [:attachment])
    |> validate_required([:opportunity_id, :attachment])
  end
end

defimpl Poison.Encoder, for: CercleApi.OpportunityAttachment do
  def encode(model, options) do
    image = ~w(.jpg .jpeg .gif .png)
    |> Enum.member?(Path.extname(model.attachment.file_name))

    attachment_url = CercleApi.OpportunityAttachmentFile.url({model.attachment, model})

    data = model
    |> Map.take([:id, :opportunity_id, :inserted_at])
    |> Map.put(:attachment_url, attachment_url)
    |> Map.put(:file_name, model.attachment.file_name)
    |> Map.put(:ext_file, Path.extname(model.attachment.file_name))

    if image do
      thumb_url = CercleApi.OpportunityAttachmentFile.url({model.attachment, model}, :thumb)
      data = Map.merge(data, %{image: true, thumb_url: thumb_url})
    else
      data = Map.put(data, :image, false)
    end

    Poison.Encoder.encode(data, options)
  end
end
