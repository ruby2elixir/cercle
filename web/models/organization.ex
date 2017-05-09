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

  def by_company(query, company_id) do
    from p in query,
      where: p.company_id == ^company_id
  end

  def order_by_date(query \\ __MODULE__) do
    from p in query,
      order_by: [desc: p.inserted_at]
  end

end
