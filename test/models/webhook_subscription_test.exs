defmodule CercleApi.WebhookSubscriptionTest do
  use CercleApi.ModelCase

  alias CercleApi.WebhookSubscription

  @valid_attrs %{event: "some content", url: "some content", user_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = WebhookSubscription.changeset(%WebhookSubscription{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = WebhookSubscription.changeset(%WebhookSubscription{}, @invalid_attrs)
    refute changeset.valid?
  end
end
