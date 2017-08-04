defmodule CercleApi.Tasks.CardNotification do
  require Logger
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias CercleApi.{Repo, Card, User, Notificaton}

  def due_date_start do
    Logger.debug "start CercleApi.Tasks.CardNotification#due_date_start"

    from_time = Timex.now |> Timex.shift(minutes: -1)
    to_time = Timex.now |> Timex.shift(minutes: 1)
    get_cards(from_time, to_time)
    |> add_to_notifications
  end

  def before_due_date do
    Logger.debug "start CercleApi.Tasks.CardNotification#before_due_date"
    from_time = Timex.now
    to_time = Timex.now |> Timex.shift(hours: 1)
    get_cards(from_time, to_time)
    |> add_to_notifications
  end

  defp get_cards(from_time, to_time) do
    query = from p in Card,
      where: p.due_date  >= ^from_time,
      where: p.due_date <= ^to_time,
      order_by: [asc: p.due_date]

    Repo.all(query)
  end

  def add_to_notifications(cards) do
    cards
    |> Enum.each(
    fn (item) ->
      with notification <- CercleApi.Notification.find_by_target("card", item.id),
      false <- is_nil(notification) do
        update_notification(notification, item)
      else
        _ ->
          create_notification(item)
      end
    end)
  end

  def create_notification(card) do
    changeset = %CercleApi.Notification{}
    |> CercleApi.Notification.changeset(
      %{
        target_type: "card",
        target_id: card.id,
        delivery_time: card.due_date,
        notification_type: "card"
      })

    CercleApi.Repo.insert(changeset)
  end

  def update_notification(notification, card) do
    changeset = notification
    |> CercleApi.Notification.changeset(
      %{
        target_type: "card",
        target_id: card.id,
        delivery_time: card.due_date,
        notification_type: "card"
      })
    CercleApi.Repo.update(changeset)
  end

end
