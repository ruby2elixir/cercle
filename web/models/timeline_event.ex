defmodule CercleApi.TimelineEvent do
  use CercleApi.Web, :model

  schema "timeline_events" do
    belongs_to :opportunity, CercleApi.Opportunity
    belongs_to :contact, CercleApi.Contact
    belongs_to :user, CercleApi.User
    belongs_to :company, CercleApi.Company
    field :event_name, :string
    field :content, :string #DEPRECATED USE
    field :metadata, :map #JSONB FIELD in POSTRESQL DB  %{}
    timestamps
  end

  @required_fields ~w(contact_id content event_name)
  @optional_fields ~w(user_id company_id metadata opportunity_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
