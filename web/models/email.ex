defmodule CercleApi.Email do
  use CercleApi.Web, :model

  schema "emails" do
    belongs_to :company, CercleApi.Company
    field :uid, :string
    field :subject, :string
    field :from_email, :string
    field :to_email, :string
    field :body, :string
    field :date, Ecto.DateTime

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:uid, :company_id, :subject, :from_email, :to_email, :body, :date])
    |> validate_required([:uid, :company_id, :subject, :from_email, :to_email, :body, :date])
    |> unique_constraint(:uid)
  end
end
