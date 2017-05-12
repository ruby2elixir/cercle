defmodule CercleApi.WebhookSubscription do
  use CercleApi.Web, :model

  schema "webhook_subscriptions" do
    field :event, :string
    field :url, :string
    belongs_to :user, CercleApi.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:user_id, :event, :url])
    |> validate_required([:user_id, :event, :url])
  end
end
