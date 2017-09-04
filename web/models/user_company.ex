defmodule CercleApi.UserCompany do
  @moduledoc false
  use CercleApi.Web, :model

  schema "users_companies" do
    field :user_id, :integer
    field :company_id, :integer
    belongs_to :user, CercleApi.User, define_field: false
    belongs_to :company, CercleApi.Company, define_field: false

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [:user_id, :company_id])
    |> validate_required([:user_id, :company_id])
  end
end
