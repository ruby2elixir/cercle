defmodule CercleApi.Notification do
  use CercleApi.Web, :model

  schema "notifications" do
    field :target_type, :string
    field :target_id, :integer
    field :delivery_time, Ecto.DateTime
    field :sent, :boolean, default: false
    field :notification_type, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:target_type, :target_id, :delivery_time, :sent, :notification_type])
    |> validate_required([:target_type, :target_id, :delivery_time, :sent, :notification_type])
  end
end
