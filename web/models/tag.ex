defmodule CercleApi.Tag do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [:id, :name, :company_id]}

  schema "tags" do
    field :name, :string
    belongs_to :company, CercleApi.Company
    many_to_many :contacts, CercleApi.Contact, join_through: CercleApi.ContactTag, on_delete: :delete_all
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:company_id, :name])
    |> validate_required([:company_id, :name])
  end

end
