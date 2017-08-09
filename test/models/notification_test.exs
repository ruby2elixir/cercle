defmodule CercleApi.NotificationTest do
  use CercleApi.ModelCase

  alias CercleApi.Notification

  @valid_attrs %{delivery_time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, notification_type: "some content", sent: true, target_id: 42, target_type: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Notification.changeset(%Notification{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Notification.changeset(%Notification{}, @invalid_attrs)
    refute changeset.valid?
  end
end
