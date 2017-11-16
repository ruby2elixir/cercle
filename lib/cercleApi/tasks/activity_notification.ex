defmodule CercleApi.Tasks.ActivityNotification do
  @moduledoc false

  require Logger
  import Ecto.Query, only: [from: 2]
  use Timex

  alias CercleApi.{Repo, Activity, Card, Notification, Mailer}

  def run do
    Enum.each(
      get_items(),
      fn (item) -> send_email(item) end
    )
  end

  def send_email(%CercleApi.Notification{notification_type: "start"} = item) do
    with target <- load_item(item),
         false <- is_nil(target), false <- is_nil(target.due_date),
           false <- is_nil(target.user), true <- target.user.notification  do
      mail = %Mailman.Email{
        subject: "#{target_name(target)} is due now",
        from: "referral@cercle.co", to: [target.user.login],
        html: email_html(target, item, "start")
      }
      Mailer.deliver(mail)
      item
      |> Notification.changeset(%{sent: true})
      |> Repo.update

    end
  end

  def send_email(%CercleApi.Notification{notification_type: "prestart"} = item) do
    with target <- load_item(item),
         false <- is_nil(target), false <- is_nil(target.due_date),
           false <- is_nil(target.user), true <- target.user.notification do
      mail = %Mailman.Email{
        subject: "#{target_name(target)} is due soon",
        from: "referral@cercle.co", to: [target.user.login],
        html: email_html(target, item, "prestart")
      }
      Mailer.deliver(mail)
      item
      |> Notification.changeset(%{sent: true})
      |> Repo.update
    end
  end

  def email_html(target, item, event_type) do
    Phoenix.View.render_to_string(
      CercleApi.EmailView, "#{event_type}_#{item.target_type}.html",
      target: target,
      receiver: target.user.user_name,
      due_date: Timex.format!(target.due_date, "{0M}/{0D}/{YYYY} {h24}:{m}"),
      contact_id: contact_id(target),
      name: target_name(target),
      url: target_url(target)
    )
  end

  def target_url(%CercleApi.Card{} = card) do
    "#{Application.get_env(:cercleApi, :site_url)}/company/#{card.company_id}/board/#{card.board_id}/card/#{card.id}"
  end

  def target_url(%CercleApi.Activity{} = activity), do: target_url(activity.card)

  def target_name(%CercleApi.Card{} = card) do
    with card <- Repo.preload(card, [:board, :board_column]) do
      "In #{card.board.name} - #{card.board_column.name}"
    end
  end

  def target_name(%CercleApi.Activity{} = activity), do: activity.title

  def contact_id(%CercleApi.Card{} = card), do:  List.first(card.contact_ids || [])
  def contact_id(%CercleApi.Activity{} = activity), do: contact_id(activity.card)
  def contact_id(_), do: []

  def load_item(%{target_type: "card"} = item) do
    Card
    |> Repo.get_by(id: item.target_id)
    |> Repo.preload([:user])
  end

  def load_item(%{target_type: "activity"} = item) do
    Activity
    |> Repo.get_by(id: item.target_id)
    |> Repo.preload([:user, :card])
  end

  def get_items do
    date = Timex.now()
    query = from p in Notification,
      where: p.delivery_time <= ^date,
      where: p.sent == false,
      where: p.target_type in ["card", "activity"],
      order_by: [asc: p.delivery_time]

    Repo.all(query)
  end
end
