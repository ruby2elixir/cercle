defmodule CercleApi.Tasks.ActivityNotification do
  require Logger
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias CercleApi.{Repo, Activity, User}

  def due_date_start do
    Logger.debug "start CercleApi.Tasks.ActivityNotification#due_date_start"

    from_time = Timex.now |> Timex.shift(minutes: -1)
    to_time = Timex.now |> Timex.shift(minutes: 1)

    get_activities(from_time, to_time)
    |> add_to_notifications
  end

  def before_due_date do
    from_time = Timex.now |> Timex.shift(hours: -1)
    to_time = Timex.now
    get_activities(from_time, to_time)
    |> add_to_notifications
  end

  defp get_activities(from_time, to_time) do
    query = from p in Activity,
      where: p.due_date  >= ^from_time,
      where: p.due_date <= ^to_time,
      order_by: [asc: p.due_date]

    query |> Repo.all
  end

  def add_to_notifications(activities) do
    activities
    |> Enum.each(
    fn (item) ->
      with notification <- CercleApi.Notification.find_by_target("activity", item.id),
      false <- is_nil(notification) do
        update_notification(notification, item)
      else
        _ ->
          create_notification(item)
      end
    end)
  end

  def create_notification(activity) do
    changeset = %CercleApi.Notification{}
    |> CercleApi.Notification.changeset(
      %{
        target_type: "activity",
        target_id: activity.id,
        delivery_time: activity.due_date,
        notification_type: "activity"
      })

    CercleApi.Repo.insert(changeset)
  end

  def update_notification(notification, activity) do
    changeset = notification
    |> CercleApi.Notification.changeset(
      %{
        target_type: "activity",
        target_id: activity.id,
        delivery_time: activity.due_date,
        notification_type: "activity"
      })
    CercleApi.Repo.update(changeset)
  end

end
