defmodule CercleApi.OpportunityAttachment do
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
