defmodule CercleApi.InvoiceTest do
  use CercleApi.ModelCase

  alias CercleApi.Invoice

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Invoice.changeset(%Invoice{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Invoice.changeset(%Invoice{}, @invalid_attrs)
    refute changeset.valid?
  end
end
