defmodule CercleApi.Board do
  use CercleApi.Web, :model
	
  schema "boards" do

    field :metadata, :map #JSONB FIELD in POSTRESQL DB  %{}
    belongs_to :company, CercleApi.Company

    timestamps
  end

  @required_fields ~w(company_id)
  @optional_fields ~w()

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
