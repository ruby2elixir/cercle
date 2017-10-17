defmodule CercleApi.Board do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :name, :type_of_card, :company_id, :board_columns
            ]}

  schema "boards" do
    field :name, :string
    field :type_of_card, :integer
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
    |> cast(params, [:company_id, :name, :archived, :type_of_card])
    |> validate_required([:company_id])
  end

  def preload_full_data(query \\ __MODULE__) do
    from p in query,
      preload: [board_columns: ^preload_query]
  end

  def preload_query do
    query_cards = from p in CercleApi.Card,
      where: p.status == 0,
      order_by: [asc: :position, desc: :inserted_at]

    from(
      CercleApi.BoardColumn, order_by: [asc: :order],
      preload: [cards: ^query_cards]
    )
  end

end
