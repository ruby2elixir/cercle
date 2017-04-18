defmodule CercleApi.Activity do
  use CercleApi.Web, :model

  @derive {Poison.Encoder, only: [
              :id, :title, :is_done, :due_date,
              :company_id, :contact_id, :user_id, :opportunity_id, :user, :contact
            ]}

  schema "activities" do
    belongs_to :opportunity, CercleApi.Opportunity
    belongs_to :user, CercleApi.User
    belongs_to :contact, CercleApi.Contact
    belongs_to :company, CercleApi.Company
    field :due_date, Ecto.DateTime
    field :is_done, :boolean, default: false
    field :title, :string

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
          :user_id, :contact_id, :company_id, :due_date, :is_done,
          :title, :opportunity_id])
    |> validate_required([:user_id, :contact_id, :company_id])
  end
end
