defmodule CercleApi.Tasks.ActivityNotification do
  require Logger
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias CercleApi.{Repo, Activity, User}

  def due_date_start do
    Logger.debug "start CercleApi.Tasks.ActivityNotification#due_date_start"

    from_time = Timex.now |> Timex.shift(minutes: -1)
    to_time = Timex.now |> Timex.shift(minutes: 1)

    query = from p in Activity,
      where: p.due_date  >= ^from_time,
      where: p.due_date <= ^to_time,
      order_by: [asc: p.due_date]

    cards = query
    |> Repo.all
    |> Repo.preload([:contact, :user])
  end

  def before_due_date do
    from_time = Timex.now |> Timex.shift(hours: 1)
    to_time = Timex.now

    query = from p in Activity,
      where: p.due_date  >= ^from_time,
      where: p.due_date <= ^to_time,
      order_by: [asc: p.due_date]

    cards = query
    |> Repo.all
    |> Repo.preload([:contact, :user])
  end
end
