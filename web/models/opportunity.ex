defmodule CercleApi.Opportunity do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :name, :description, :status, :contact_ids
            ]}

  schema "opportunities" do
    field :name, :string
    field :description, :string
    field :status, :integer, default: 0 #### 0 OPEN, 1 CLOSED
    belongs_to :main_contact, CercleApi.Contact
    field :contact_ids, {:array, :integer}
    belongs_to :user, CercleApi.User
    belongs_to :company, CercleApi.Company
    belongs_to :board, CercleApi.Board
    belongs_to :board_column, CercleApi.BoardColumn
    timestamps
  end

  @required_fields ~w(main_contact_id user_id company_id)
  @optional_fields ~w(name status contact_ids board_id board_column_id description)

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
