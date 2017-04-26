defmodule CercleApi.OpportunityAttachment do
  use CercleApi.Web, :model

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
    |> cast(params, [:attachment])
    |> validate_required([:attachment])
  end
end
