defmodule CercleApi.Contact do
  @moduledoc """
  Contact is the main table where user save informations about contacts
  """
  use CercleApi.Web, :model
  alias CercleApi.Contact

   @derive {Poison.Encoder, only: [
               :id, :first_name, :last_name, :email, :phone, :job_title, :description,
               :company_id, :updated_at
             ]}

  schema "contacts" do
    belongs_to :user, CercleApi.User
    belongs_to :organization, CercleApi.Organization
    belongs_to :company, CercleApi.Company
    field :first_name, :string
    field :last_name, :string
    field :email, :string
    field :phone, :string
    field :description, :string
    field :job_title, :string
    field :cards, {:array, :map}, virtual: true

    many_to_many :tags, CercleApi.Tag, join_through: CercleApi.ContactTag,
      on_delete: :delete_all
    field :data, :map #JSONB FIELD in POSTRESQL DB  for Custom Fields

    has_many :activities, CercleApi.Activity, foreign_key: :contact_id,
      on_delete: :delete_all
    has_many :timeline_event, CercleApi.TimelineEvent, foreign_key: :contact_id,
      on_delete: :delete_all
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, [
          :company_id, :first_name, :last_name, :data, :organization_id, :user_id,
          :email, :phone, :description, :job_title
        ])
    |> validate_required([:company_id, :last_name])
  end

  def cards(contact, query \\ CercleApi.Card) do
    cards_query = from c in query,
      where: fragment("? = ANY (?)", ^contact.id, c.contact_ids),
      order_by: [desc: c.inserted_at],
      preload: [:board, :board_column]
    CercleApi.Repo.all(cards_query)
  end

  def card(contact) do
    open_card = from opp in CercleApi.Card,
      limit: 1,
      where: fragment("? = ANY (?)", ^contact.id, opp.contact_ids),
      where: opp.status == 0,
      order_by: [desc: opp.inserted_at],
      preload: [:board, :board_column]
    CercleApi.Repo.one(open_card)
  end

  def involved_in_cards(contact) do
    query = from card in CercleApi.Card,
      where: fragment("? = ANY (?)", ^contact.id, card.contact_ids),
      where: card.status == 0,
      order_by: [desc: card.inserted_at],
      preload: [:board_column, board: [:board_columns]]
    CercleApi.Repo.all(query)
  end

  def all_cards(contact) do
    query = from card in CercleApi.Card,
      where: fragment("? = ANY (?)", ^contact.id, card.contact_ids),
      order_by: [desc: card.inserted_at],
      preload: [:board_column, board: [:board_columns]]
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
      :organization, :tags,
      activities: [:user],
      company: [:users, boards: [:board_columns]],
      timeline_event: ^comments_query
    ]
  end

  def preload_cards(contacts) when is_list(contacts) do
    Enum.map(contacts, &preload_cards(&1))
  end

  def preload_cards(contact \\ %CercleApi.Contact{}) do
    Map.merge(contact, %{contacts: __MODULE__.cards(contact)})
  end

  def full_name(contact) do
    String.trim(Enum.join([contact.first_name, contact.last_name], " "))
  end
end

defimpl Poison.Encoder, for: CercleApi.Contact do
  def encode(model, options) do
    model
    |> Map.take([
      :id, :first_name, :last_name, :email, :phone, :job_title,
      :description, :company_id, :updated_at])
    |> Map.put(:name, CercleApi.Contact.full_name(model))
    |> Poison.Encoder.encode(options)
  end
end
