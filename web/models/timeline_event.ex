defmodule CercleApi.TimelineEvent do
  use CercleApi.Web, :model

  schema "timeline_events" do
    belongs_to :contact, CercleApi.Contact
    belongs_to :user, CercleApi.User
    belongs_to :company, CercleApi.Company
    field :action_type, :string
    field :content, :string

    timestamps
  end

  @required_fields ~w(contact_id content action_type)
  @optional_fields ~w(user_id company_id)

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
