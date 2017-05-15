defmodule CercleApi.Opportunity do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :name, :description, :status, :contact_ids, :user_id,
              :board_id, :board_column_id
            ]}

  schema "opportunities" do
    field :name, :string
    field :description, :string
    field :status, :integer, default: 0 #### 0 OPEN, 1 CLOSED
    belongs_to :main_contact, CercleApi.Contact
    field :contact_ids, {:array, :integer}
    belongs_to :user, CercleApi.User
    belongs_to :company, CercleApi.Company
    belongs_to :board, CercleApi.Board
    belongs_to :board_column, CercleApi.BoardColumn
    has_many :activities, CercleApi.Activity
    has_many :timeline_event, CercleApi.TimelineEvent,
      foreign_key: :opportunity_id
    has_many :attachments, CercleApi.OpportunityAttachment,
      foreign_key: :opportunity_id, on_delete: :delete_all
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
          :main_contact_id, :user_id, :company_id, :name, :status,
          :contact_ids, :board_id, :board_column_id, :description
        ])
    |> validate_required([:main_contact_id, :user_id, :company_id])
  end

  def contacts(opportunity) do
    opportunity_contacts = from contact in CercleApi.Contact,
      where: contact.id in ^opportunity.contact_ids
    CercleApi.Repo.all(opportunity_contacts)
  end

  def preload_data(query \\ %CercleApi.Opportunity{}) do
    comments_query = from c in CercleApi.TimelineEvent,
      order_by: [desc: c.inserted_at],
      preload: :user

    from q in query, preload: [
      :attachments,
      activities: [:contact, :user],
      timeline_event: ^comments_query
    ]
  end
end

defimpl Poison.Encoder, for: CercleApi.Opportunity do
  def encode(model, options) do
    model
    |> Map.take(
      [:id, :name, :description, :status, :contact_ids, :user_id, :board_id, :board_column_id]
    )
    |> Poison.Encoder.encode(options)
  end
end
