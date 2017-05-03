defmodule CercleApi.Board do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :name, :company_id, :board_columns
            ]}

  schema "boards" do
    field :name, :string
    belongs_to :company, CercleApi.Company
    has_many :board_columns, CercleApi.BoardColumn
    field :archived, :boolean
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:company_id, :name, :archived])
    |> validate_required([:company_id])
  end

end
