defmodule CercleApi.Tasks.ActivityNotificationTest do
  use CercleApi.ModelCase
  import CercleApi.Factory
  alias CercleApi.{Repo, Notification}

  test "run" do
    user = insert(:user, notification: true)
    user1 = insert(:user, notification: false)
    card = insert(:card, user: nil, due_date: Timex.shift(Timex.now(), minutes: -10))
    card1 = insert(:card, user: user, due_date: Timex.shift(Timex.now(), minutes: -10))
    card2 = insert(:card, user: user1, due_date: Timex.shift(Timex.now(), minutes: -10))

    activity = insert(:activity, user: user, due_date: Timex.shift(Timex.now(), minutes: -10))

    n = insert(:notification, target_type: "card", target_id: card.id,
      delivery_time: Timex.shift(Timex.now(), minutes: -10))

    n1 = insert(:notification, target_type: "card", target_id: card1.id,
      delivery_time: Timex.shift(Timex.now(), minutes: -10))

    n2 = insert(:notification, target_type: "card", target_id: card2.id,
      delivery_time: Timex.shift(Timex.now(), minutes: -10))

    na = insert(:notification, target_type: "activity", target_id: activity.id,
      delivery_time: Timex.shift(Timex.now(), minutes: -10))

    assert CercleApi.Tasks.ActivityNotification.email_html(
      card1, n1, "prestart"
    ) =~ ~r/<a href="\/company\/#{card1.company_id}\/board\/#{card1.board_id}\/card\/#{card1.id}">link to the card<\/a>/

    assert CercleApi.Tasks.ActivityNotification.email_html(
      card1, n1, "start"
    ) =~ ~r/<a href="\/company\/#{card1.company_id}\/board\/#{card1.board_id}\/card\/#{card1.id}">link to the card<\/a>/

    assert CercleApi.Tasks.ActivityNotification.email_html(
      activity, na, "prestart"
    ) =~ ~r/<a href="\/company\/#{activity.card.company_id}\/board\/#{activity.card.board_id}\/card\/#{activity.card.id}">link to the card<\/a>/


    CercleApi.Tasks.ActivityNotification.run
    assert Repo.get(Notification, n1.id).sent
    refute Repo.get(Notification, n.id).sent
    refute Repo.get(Notification, n2.id).sent

    assert Repo.get(Notification, na.id).sent
  end
end
