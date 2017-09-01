defmodule CercleApi.Company do
  @moduledoc """
  Company reprends the group of users who use Cercle CRM.
  """
  use CercleApi.Web, :model
  use Arc.Ecto.Schema

  @derive {Poison.Encoder, only: [:id, :title, :logo_image, :data_fields]}

  schema "companies" do
    field :title, :string
    field :logo_image, CercleApi.CompanyLogoImage.Type

    has_many :user_companies, CercleApi.UserCompany
    has_many :users, through: [:user_companies, :user]

    has_many :contacts, CercleApi.Contact
    has_many :organizations, CercleApi.Organization
    has_many :cards, CercleApi.Card
    has_many :boards, CercleApi.Board
    field :data_fields, :map
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ :invalid) do
    model
    |> cast(params, [:title])
    |> cast_attachments(params, [:logo_image])
    |> validate_required([:title])
  end

end
