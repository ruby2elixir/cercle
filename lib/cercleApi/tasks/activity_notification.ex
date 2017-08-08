defmodule CercleApi.Tasks.ActivityNotification do

  require Logger
  import Ecto.Query, only: [from: 1, from: 2]
  use Timex

  alias CercleApi.{Repo, Activity, Card, Notification, Mailer}

  def run do
    IO.puts "run ActivityNotification"
    send_current_notification
    send_prestart_notification
  end

  def send_current_notification do
    from_time = Timex.now |> Timex.shift(minutes: -5)
    to_time = Timex.now |> Timex.shift(minutes: 1)
    Enum.each(
      get_items(from_time, to_time),
      fn (item) -> send_email(item, "start") end
    )
  end

  def send_prestart_notification do
    from_time = Timex.now|> Timex.shift(minutes: 60)
    to_time = Timex.now |> Timex.shift(minutes: 65)
    Enum.each(
      get_items(from_time, to_time),
      fn (item) -> send_email(item, "before_start") end
    )
  end

  def send_email(item, "start") do
    target = load_item(item)
    if target.user.notification do
      mail = %Mailman.Email{
        subject: "Start",
        from: "no-reply@cercle.co",
        to: [target.user.login],
        html: email_html(target, item.target_type)
      }
      Mailer.deliver(mail)
      item
      |> Notification.changeset(%{sent: true})
      |> Repo.update
    end
  end

  def send_email(item, "before_start") do
    target = load_item(item)
    if target.user.notification do
      mail = %Mailman.Email{
        subject: "Before Start",
        from: "no-reply@cercle.co",
        to: [target.user.login],
        html: email_html(target, item.target_type)
      }
      Mailer.deliver(mail)
    end
  end

  defp email_html(target, template_type) do
    Phoenix.View.render_to_string(
      CercleApi.EmailView, "start_#{template_type}.html",
      target: target,
      receiver: target.user.user_name
    )
  end

  defp load_item(%{target_type: "card"} = item) do
    Card
    |> Repo.get_by(id: item.target_id)
    |> Repo.preload([:user])
  end

  defp load_item(%{target_type: "activity"} = item) do
    Activity
    |> Repo.get_by(id: item.target_id)
    |> Repo.preload([:user])
  end

  defp get_items(from_time, to_time) do
    query = from p in Notification,
      where: p.delivery_time  >= ^from_time,
      where: p.delivery_time <= ^to_time,
      where: p.sent == false,
      where: p.target_type in ["card", "active"],
      order_by: [asc: p.delivery_time]

    Repo.all(query)
  end
end
