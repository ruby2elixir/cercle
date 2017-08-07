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
    |> CercleApi.Repo.insert
  end

  def update_notification(event, item) do
    item
    |> changeset(event)
    |> CercleApi.Repo.update
  end

  def changeset(item = %CercleApi.Card{}, event) do
    event
    |> CercleApi.Notification.changeset(
      %{
        target_type: "card",
        target_id: item.id,
        delivery_time: item.due_date,
        notification_type: "card"
      })
  end

  def changeset(item = %CercleApi.Activity{}, event) do
    event
    |> CercleApi.Notification.changeset(
      %{
        target_type: "activity",
        target_id: item.id,
        delivery_time: item.due_date,
        notification_type: "activity"
      })
  end

  def find_item(item = %CercleApi.Card{}) do
    CercleApi.Notification.find_by_target("card", item.id)
  end

  def find_item(item = %CercleApi.Activity{}) do
    CercleApi.Notification.find_by_target("activity", item.id)
  end
end
