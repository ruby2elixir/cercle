defmodule CercleApi.CompanyBenifitTest do
  use CercleApi.ModelCase

  alias CercleApi.CompanyBenifit

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = CompanyBenifit.changeset(%CompanyBenifit{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = CompanyBenifit.changeset(%CompanyBenifit{}, @invalid_attrs)
    refute changeset.valid?
  end
end
