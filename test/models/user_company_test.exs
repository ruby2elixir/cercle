defmodule CercleApi.UserCompanyTest do
  use CercleApi.ModelCase

  alias CercleApi.UserCompany

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = UserCompany.changeset(%UserCompany{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = UserCompany.changeset(%UserCompany{}, @invalid_attrs)
    refute changeset.valid?
  end
end
