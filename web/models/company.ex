defmodule CercleApi.Company do
  @moduledoc """
  Company reprends the group of users who use Cercle CRM.
  """
  use CercleApi.Web, :model
  use Arc.Ecto.Model

  schema "companies" do
    field :title, :string
    field :logo_image, CercleApi.CompanyLogoImage.Type
    has_many :users, CercleApi.User
    has_many :contacts, CercleApi.Contact
    has_many :organizations, CercleApi.Organization
    has_many :opportunities, CercleApi.Opportunity
    has_many :boards, CercleApi.Board
    field :data_fields, :map 
    timestamps
  end

  @required_fields ~w(title)
  @optional_fields ~w( )
  @required_file_fields ~w()
  @optional_file_fields ~w(logo_image)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_attachments(params, @required_file_fields, @optional_file_fields)
  end
  
end
