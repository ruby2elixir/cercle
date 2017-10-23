defmodule CercleApi.Company do
  @moduledoc """
  Company reprends the group of users who use Cercle CRM.
  """
  use CercleApi.Web, :model
  use Arc.Ecto.Schema
  alias CercleApi.{Repo, UserCompany}
  @derive {Poison.Encoder, only: [:id, :title, :logo_image, :data_fields]}

  schema "companies" do
    field :title, :string
    field :logo_image, CercleApi.CompanyLogoImage.Type
    field :api_token, :string

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
    |> cast(params, [:title, :api_token])
    |> cast_attachments(params, [:logo_image])
    |> validate_required([:title])
  end

  def get_or_set_api_token(company) do
    token = company.api_token
    if is_nil(token) do 
      token = Ecto.UUID.generate
      cs = changeset(company, %{"api_token": token})
      Repo.update(cs)
    end
    token
  end

  def add_user_to_company(user, company) do
    query = from uc in UserCompany,
      where: uc.user_id == ^user.id and uc.company_id == ^company.id
    user_company = query
    |> Ecto.Query.first
    |> Repo.one

    if !user_company do
      %UserCompany{}
      |> UserCompany.changeset(%{user_id: user.id, company_id: company.id})
      |> Repo.insert
    end
  end

  def user_companies(user) do
    Repo.all(
      from c in __MODULE__,
      join: p in assoc(c, :users),
      where: p.id == ^user.id
    )
  end

  def get_company(user, company_id) when not is_nil(company_id) do
    query = from c in __MODULE__,
      join: p in assoc(c, :users),
      where: p.id == ^user.id,
      where: c.id == ^company_id
    query
    |> Ecto.Query.first
    |> Repo.one
  end

  def get_company(user, company_id \\ nil) do
    query = from c in __MODULE__,
      join: p in assoc(c, :users),
      where: p.id == ^user.id
    query
    |> Ecto.Query.first
    |> Repo.one
  end
end

defimpl Poison.Encoder, for: CercleApi.Company do
  def encode(model, options) do
    model
    |> Map.take([:id, :title])
    |> Map.put(:logo_url, CercleApi.CompanyLogoImage.url({model.logo_image, model}, :small))
    |> Poison.Encoder.encode(options)
  end
end
