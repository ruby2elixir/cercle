defmodule CercleApi.CompanyServiceTest do
  use CercleApi.ModelCase

  alias CercleApi.CompanyService

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = CompanyService.changeset(%CompanyService{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = CompanyService.changeset(%CompanyService{}, @invalid_attrs)
    refute changeset.valid?
  end
end
