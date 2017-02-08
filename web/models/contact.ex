defmodule CercleApi.Contact do
  use CercleApi.Web, :model
	
  schema "contacts" do
    belongs_to :user, CercleApi.User
    belongs_to :organization, CercleApi.Organization
    belongs_to :company, CercleApi.Company
    field :name, :string
    field :email, :string
    field :phone, :string
    field :description, :string
    field :job_title, :string

    field :data, :map #JSONB FIELD in POSTRESQL DB  %{ cercle_string_name, }

    ## FIELDS CERCLE AVAILABLE
    #cercle_name

    #cercle_phone
    #cercle_email
    #cercle_job_title
    #cercle_rating
    #cercle_description
    #cercle_status

    has_many :activities, CercleApi.Activity, foreign_key: :contact_id, on_delete: :delete_all
    has_many :timeline_event, CercleApi.TimelineEvent, foreign_key: :contact_id, on_delete: :delete_all
    has_many :opportunities, CercleApi.Opportunity, foreign_key: :main_contact_id, on_delete: :delete_all
    timestamps
  end

  @required_fields ~w(company_id)
  @optional_fields ~w(data organization_id user_id email name phone description job_title)

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
