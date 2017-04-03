defmodule CercleApi.Contact do
  @moduledoc """
  Contact is the main table where user save informations about contacts
  """
  use CercleApi.Web, :model
  alias CercleApi.Contact

   @derive {Poison.Encoder, only: [
               :id, :name, :email, :phone, :job_title, :description,
               :company_id, :updated_at
             ]}

  schema "contacts" do
    belongs_to :user, CercleApi.User
    belongs_to :organization, CercleApi.Organization
    belongs_to :company, CercleApi.Company
    field :name, :string
    field :email, :string
    field :phone, :string
    field :description, :string
    field :job_title, :string
    many_to_many :tags, CercleApi.Tag, join_through: CercleApi.ContactTag
    field :data, :map #JSONB FIELD in POSTRESQL DB  for Custom Fields

    has_many :activities, CercleApi.Activity, foreign_key: :contact_id, on_delete: :delete_all
    has_many :timeline_event, CercleApi.TimelineEvent, foreign_key: :contact_id, on_delete: :delete_all
    has_many :opportunities, CercleApi.Opportunity, foreign_key: :main_contact_id, on_delete: :delete_all
    timestamps
  end

  @required_fields ~w(company_id name)
  @optional_fields ~w(data organization_id user_id email phone description job_title)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def opportunity(contact) do
    open_opportunity = from opp in CercleApi.Opportunity,
      limit: 1,
      where: fragment("? = ANY (?)", ^contact.id, opp.contact_ids),
      where: opp.status == 0,
      order_by: [desc: opp.inserted_at],
      preload: [:board, :board_column]
    CercleApi.Repo.one(open_opportunity)
  end

  def involved_in_opportunities(contact) do
    query = from opportunity in CercleApi.Opportunity,
      where: fragment("? = ANY (?)", ^contact.id, opportunity.contact_ids),
      where: opportunity.status == 0,
      order_by: [desc: opportunity.inserted_at]
    CercleApi.Repo.all(query)
  end

  def activities_in_progress(contact) do
    query = from activity in CercleApi.Activity,
      where: activity.contact_id == ^contact.id,
      where: activity.is_done == false,
      order_by: [desc: activity.inserted_at]
    CercleApi.Repo.all(query) |> CercleApi.Repo.preload [:user]
  end

  def preload_data(query \\ %Contact{}) do
    comments_query = from c in CercleApi.TimelineEvent, order_by: [desc: c.inserted_at], preload: :user

    from q in query, preload: [
      :organization, :tags, :opportunities,
      activities: [:user],
      company: [:users, boards: [:board_columns]],
      timeline_event: ^comments_query
    ]
  end

end
