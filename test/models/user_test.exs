defmodule CercleApi.UserTest do
  use CercleApi.ModelCase

  alias CercleApi.User

  @valid_attrs %{login: "test@example.com"}
  @invalid_attrs %{zinzin: "test"}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
