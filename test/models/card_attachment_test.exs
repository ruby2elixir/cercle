defmodule CercleApi.CardAttachmentTest do
  use CercleApi.ModelCase

  alias CercleApi.CardAttachment

  @invalid_attrs %{}

  test "changeset with invalid attributes" do
    changeset = CardAttachment.changeset(%CardAttachment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
