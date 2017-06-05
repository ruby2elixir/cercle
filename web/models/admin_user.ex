defmodule CercleApi.AdminUser do
  use CercleApi.Web, :model
  @system_user_email "admin@cercle.com"

  schema "admin_users" do
    field :name, :string
    field :email, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email])
    |> validate_required([:email])
  end

  def system_user do
    case CercleApi.Repo.get_by(__MODULE__, email: @system_user_email) do
      nil ->
        {_, user } = %CercleApi.AdminUser{}
        |> changeset(%{"email" => @system_user_email, "name" => "System admin"})
        |> CercleApi.Repo.insert
        user
      user -> user
    end
  end
end
