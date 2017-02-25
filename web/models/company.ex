defmodule CercleApi.Company do
  use CercleApi.Web, :model
  use Arc.Ecto.Model

  @derive {Poison.Encoder, only: [ :id, :title, :logo_image, :data_fields ]}

  schema "companies" do
    field :title, :string
    field :logo_image, CercleApi.CompanyLogoImage.Type
    has_many :users, CercleApi.User
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
