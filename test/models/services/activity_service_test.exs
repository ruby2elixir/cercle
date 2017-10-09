defmodule CercleApi.ActivityServiceTest do
  use CercleApi.ModelCase
  import CercleApi.Factory
  alias CercleApi.{ActivityService, Card, Activity, Repo}

  test "add card to notification" do
    user = insert(:user)
    card = insert(:card, user: user, due_date: Timex.now())
    ActivityService.add(card)
    ActivityService.add(card)
    assert Repo.aggregate(Card, :count, :id) == 1
  end

  test "add activity to notification" do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    activity = insert(:activity, user: user, company: company,
      due_date: Timex.now()
    )
    ActivityService.add(activity)
    ActivityService.add(activity)
    assert Repo.aggregate(Activity, :count, :id) == 1

    due_date = Timex.shift(Timex.now(), days: 12)
    activity
    |> Activity.changeset(%{due_date: due_date})
    |> Repo.update

    ActivityService.add(activity)

    assert Repo.aggregate(Activity, :count, :id) == 1
    item = Repo.one(from x in Activity, limit: 1)
    item_due_date = Ecto.DateTime.dump(item.due_date)
    |> elem(1)
    |> Timex.DateTime.Helpers.construct("Etc/UTC")
    |> Timex.to_unix

    assert item_due_date == Timex.to_unix(due_date)
  end

  test "delete notification" do
    user = insert(:user, notification: true)
    card = insert(:card, user: user, due_date: Timex.shift(Timex.now(), minutes: -10))

    activity = insert(:activity, user: user, due_date: Timex.shift(Timex.now(), minutes: -10))

    nc = insert(:notification, target_type: "card", target_id: card.id,
      delivery_time: Timex.shift(Timex.now(), minutes: -10))
    na = insert(:notification, target_type: "activity", target_id: activity.id,
      delivery_time: Timex.shift(Timex.now(), minutes: -10))

    assert Repo.aggregate(CercleApi.Notification, :count, :id) == 2
    ActivityService.delete("card", card.id)
    ActivityService.delete("activity", activity.id)
    assert Repo.aggregate(CercleApi.Notification, :count, :id) == 0
  end
end
