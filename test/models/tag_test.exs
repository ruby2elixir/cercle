defmodule CercleApi.TagTest do
  use CercleApi.ModelCase

  alias CercleApi.Tag

  @valid_attrs %{name: "Tag1", company_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end
end
