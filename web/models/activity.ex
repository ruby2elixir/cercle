defmodule CercleApi.Activity do
  use CercleApi.Web, :model
  use Timex

  @derive {Poison.Encoder, only: [
              :id, :title, :is_done, :due_date,
              :company_id, :contact_id, :user_id, :card_id, :user, :contact
            ]}

  schema "activities" do
    belongs_to :card, CercleApi.Card
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
          :title, :card_id])
    |> validate_required([:user_id, :contact_id, :card_id, :company_id])
  end

  def by_status(query, status \\ false) do
    from p in query,
      where: p.is_done == ^status
  end

  def order_by_date(query \\ __MODULE__, direction \\ :desc) do
    values = case direction do
               :asc -> [asc: :due_date]
               _ -> [desc: :due_date]
             end
    from(p in query, order_by: ^values)
  end

  def in_progress(query) do
    by_status(query, true)
  end

  def by_user(query, user_id) do
    from p in query,
      where: p.user_id == ^user_id
  end

  def by_company(query, company_id) do
    from p in query,
      where: p.company_id == ^company_id
  end

  def start_in(query, minutes) when is_binary(minutes) do
    start_in(query, String.to_integer(minutes))
  end

  def start_in(query, minutes) when is_integer(minutes) do
    start_date = Timex.now()
    end_date = Timex.shift(Timex.now(), minutes: minutes)
    from p in query,
      where: p.due_date > ^start_date,
      where: p.due_date <= ^end_date
  end

  def by_date(query, :overdue) do
    from_time = Timex.now |> Timex.beginning_of_day
    from p in query,
      where: p.due_date <= ^from_time
  end

  def list(user) do
    __MODULE__
    |> in_progress
    |> by_user(user.id)
    |> by_company(user.company_id)
    |> order_by_date
  end

  def today(user) do
    from_time = user.time_zone |> Timex.now |> Timex.beginning_of_day
    to_time = user.time_zone |> Timex.now |> Timex.end_of_day

    query = from p in __MODULE__,
      where: p.is_done == false,
      where: p.user_id == ^user.id,
      where: p.company_id == ^user.company_id,
      where: p.due_date  >= ^from_time,
      where: p.due_date <= ^to_time,
      order_by: [asc: p.due_date]

    query
    |> CercleApi.Repo.all
    |> CercleApi.Repo.preload([:contact, :user])
  end

  def overdue(user) do
    from_time = user.time_zone |> Timex.now |> Timex.beginning_of_day

    query = from p in __MODULE__,
      where: p.is_done == false,
      where: p.user_id == ^user.id,
      where: p.company_id == ^user.company_id,
      where: p.due_date  <= ^from_time,
      where: not is_nil(p.contact_id),
      order_by: [asc: p.due_date]

    query
    |> CercleApi.Repo.all
    |> CercleApi.Repo.preload([:contact, :user])
  end

  def later(user) do
    from_time = user.time_zone |> Timex.now |> Timex.beginning_of_day
    to_time = user.time_zone |> Timex.now |> Timex.end_of_day

    query = from p in __MODULE__,
      where: p.is_done == false,
      where: p.user_id == ^user.id,
      where: p.company_id == ^user.company_id,
      where: p.due_date >= ^to_time,
      order_by: [asc: p.due_date]

    query
    |> CercleApi.Repo.all
    |> CercleApi.Repo.preload([:contact, :user])
  end
end
