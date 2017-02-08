defmodule CercleApi.CompanyTest do
  use CercleApi.ModelCase

  alias CercleApi.Company

  @valid_attrs %{description1: "some content", description2: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Company.changeset(%Company{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Company.changeset(%Company{}, @invalid_attrs)
    refute changeset.valid?
  end
end
