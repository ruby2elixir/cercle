defmodule CercleApi.EmailTest do
  use CercleApi.ModelCase

  alias CercleApi.Email

  @valid_attrs %{body: "some content", company_id: 42, date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}, uid: "some content", from_email: "some content", subject: "some content", to_email: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Email.changeset(%Email{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Email.changeset(%Email{}, @invalid_attrs)
    refute changeset.valid?
  end
end
