defmodule CercleApi.UserCompany do
  use CercleApi.Web, :model

  schema "users_companies" do
    belongs_to :user, CercleApi.User
    belongs_to :company, CercleApi.Company

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end
