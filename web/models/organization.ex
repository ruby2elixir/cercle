defmodule CercleApi.Organization do
  @moduledoc """
  Organization is the place where is working a contact.
  """

  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :user_id, :company_id, :name, :website,
              :description, :data
            ]}

  schema "organizations" do
    belongs_to :user, CercleApi.User
    belongs_to :company, CercleApi.Company
    has_many :contacts, CercleApi.Contact, on_delete: :delete_all
    field :name, :string
    field :website, :string
    field :description, :string
    field :data, :map

    ## FIELDS CERCLE AVAILABLE
    #cercle_name
    #cercle_url
    #cercle_description

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [:company_id, :name, :data, :website, :description])
    |> validate_required([:company_id, :name])
  end

end
