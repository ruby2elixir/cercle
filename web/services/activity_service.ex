defmodule CercleApi.ActivityService do
  @moduledoc false

  require Logger
  import Ecto.Query, only: [from: 1, from: 2]

  use Timex

  alias CercleApi.{Repo, Notificaton}

  def add(%{due_date: due_date} = item) when is_nil(due_date), do: :ok
  def add(item) do
    with event <- find_item(item), false <- is_nil(event) do
      update_notification(event, item)
    else
      _ ->
        create_notification(item)
    end
  end

  def delete(object_type, id) do
    CercleApi.Notification
    |> Ecto.Query.where(target_type: ^object_type, target_id: ^id)
    |> Repo.delete_all
  end

  defp create_notification(item) do
    item
    |> changeset(%CercleApi.Notification{})
    |> Repo.insert
    create_prestart_notification(item)
  end

  defp create_prestart_notification(item) do
    item
    |> changeset(%CercleApi.Notification{})
    |> Ecto.Changeset.put_change(:notification_type, "prestart")
    |> Ecto.Changeset.put_change(:delivery_time, prestart_date(item.due_date))
    |> Repo.insert
  end

  defp update_notification(event, item) do
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

  defp update_prestart_notification(event, item) do
    item
    |> changeset(event)
    |> Ecto.Changeset.put_change(:notification_type, "prestart")
    |> Ecto.Changeset.put_change(:delivery_time, prestart_date(item.due_date))
    |> CercleApi.Repo.update
  end

  defp changeset(item = %CercleApi.Card{}, event) do
    event
    |> CercleApi.Notification.changeset(
      %{
        target_type: "card",
        target_id: item.id,
        delivery_time: item.due_date,
        notification_type: "start"
      })
  end

  defp changeset(item = %CercleApi.Activity{}, event) do
    event
    |> CercleApi.Notification.changeset(%{
        target_type: "activity",
        target_id: item.id,
        delivery_time: item.due_date,
        notification_type: "start"
      })
  end

  defp find_item(item = %CercleApi.Card{}) do
    CercleApi.Notification.find_by_target("card", item.id, "start")
  end

  defp find_item(item = %CercleApi.Activity{}) do
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
