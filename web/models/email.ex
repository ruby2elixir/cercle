defmodule CercleApi.Email do
  @moduledoc """
  Inbound email history
  """

  use CercleApi.Web, :model

  schema "emails" do
    belongs_to :company, CercleApi.Company
    field :uid, :string
    field :subject, :string
    field :from_email, :string
    field :to, {:array, :string}
    field :cc, {:array, :string}
    field :bcc, {:array, :string}
    field :body, :string
    field :body_text, :string
    field :date, Ecto.DateTime
    field :meta, :map

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:uid, :company_id, :subject, :from_email, :to, :cc, :bcc, :meta, :body, :body_text, :date])
    |> validate_required([:uid, :company_id, :from_email, :to, :meta, :date])
    |> unique_constraint(:uid)
  end
end
