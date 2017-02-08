defmodule CercleApi.RewardTest do
  use CercleApi.ModelCase

  alias CercleApi.Reward

  @valid_attrs %{company_id: 42, email: "some content", reward_value: "some content", status: "some content", user_id: 42, user_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Reward.changeset(%Reward{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Reward.changeset(%Reward{}, @invalid_attrs)
    refute changeset.valid?
  end
end
