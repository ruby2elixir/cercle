defmodule CercleApi.TimelineEvent do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :event_name, :content, :metadata,
              :company_id, :contact_id, :user_id, :card_id, :inserted_at, :user
            ]}
  schema "timeline_events" do
    belongs_to :card, CercleApi.Card
    belongs_to :contact, CercleApi.Contact
    belongs_to :user, CercleApi.User
    belongs_to :company, CercleApi.Company
    field :event_name, :string
    field :content, :string #DEPRECATED USE
    field :metadata, :map #JSONB FIELD in POSTRESQL DB  %{}
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
          :content, :event_name, :card_id, :user_id,
          :company_id, :metadata, :contact_id
        ])
    |> validate_required([:content, :event_name, :card_id, :company_id, :user_id])
  end

  def recent(board, limit \\ 10) do
    query = from e in __MODULE__,
      join: o in assoc(e, :card),
      where: o.board_id == ^board.id,
      select: e,
      limit: ^limit,
      order_by: [desc: e.inserted_at]

    CercleApi.Repo.all(query)
  end
end
