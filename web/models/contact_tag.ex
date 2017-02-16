defmodule CercleApi.ContactTag do
  use CercleApi.Web, :model
	
  schema "contacts_tags" do
    belongs_to :contact, CercleApi.Contact
    belongs_to :tag, CercleApi.Tag
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, [])
  end
	
end
