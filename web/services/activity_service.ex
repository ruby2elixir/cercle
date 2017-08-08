defmodule ActivityService do
  @moduledoc """
  Service to handle
  """

  require Logger
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias CercleApi.{Repo, Notificaton}

  def add(item) do
    with event <- find_item(item), false <- is_nil(event) do
      update_notification(event, item)
    else
      _ ->
        create_notification(item)
    end
  end

  def create_notification(item) do
    item
    |> changeset(%CercleApi.Notification{})
    |> Repo.insert
    create_prestart_notification(item)
  end

  def create_prestart_notification(item) do
    item
    |> changeset(%CercleApi.Notification{})
    |> Ecto.Changeset.put_change(:notification_type, "prestart")
    |> Ecto.Changeset.put_change(:delivery_time, prestart_date(item.due_date))
    |> Repo.insert
  end

  def update_notification(event, item) do
    item
    |> changeset(event)
    |> CercleApi.Repo.update
    with prestart_event <- CercleApi.Notification.find_by_target(
          event.target_type, event.target_id, "prestart"),
         false <- is_nil(prestart_event) do
      update_prestart_notification(prestart_event, item)
    else
      _ ->
        create_prestart_notification(item)
    end
  end

  def update_prestart_notification(event, item) do
    item
    |> changeset(event)
    |> Ecto.Changeset.put_change(:notification_type, "prestart")
    |> Ecto.Changeset.put_change(:delivery_time, prestart_date(item.due_date))
    |> CercleApi.Repo.update
  end

  def changeset(item = %CercleApi.Card{}, event) do
    event
    |> CercleApi.Notification.changeset(
      %{
        target_type: "card",
        target_id: item.id,
        delivery_time: item.due_date,
        notification_type: "start"
      })
  end

  def changeset(item = %CercleApi.Activity{}, event) do
    event
    |> CercleApi.Notification.changeset(
      %{
        target_type: "activity",
        target_id: item.id,
        delivery_time: item.due_date,
        notification_type: "start"
      })
  end

  def find_item(item = %CercleApi.Card{}) do
    CercleApi.Notification.find_by_target("card", item.id, "start")
  end

  def find_item(item = %CercleApi.Activity{}) do
    CercleApi.Notification.find_by_target("activity", item.id, "start")
  end

  defp prestart_date(date) do
    date
    |> Ecto.DateTime.dump
    |> elem(1)
    |> Timex.DateTime.Helpers.construct("Etc/UTC")
    |> Timex.shift(hours: -1)
    |> Timex.to_erl
    |> Ecto.DateTime.from_erl
  end

end
