defmodule CercleApi.Board do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :name, :company_id
            ]}

  schema "boards" do
    field :name, :string
    belongs_to :company, CercleApi.Company
    has_many :board_columns, CercleApi.BoardColumn
    timestamps
  end

  @required_fields ~w(company_id)
  @optional_fields ~w(name)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end
