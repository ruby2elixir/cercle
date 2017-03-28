defmodule CercleApi.BoardColumn do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :name, :order, :board_id
            ]}

  schema "boards_columns" do
    field :name, :string
    field :order, :integer
    belongs_to :board, CercleApi.Board
    timestamps
  end

  @required_fields ~w(board_id)
  @optional_fields ~w(name order)

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
