defmodule CercleApi.OpportunityAttachmentTest do
  use CercleApi.ModelCase

  alias CercleApi.OpportunityAttachment

  @valid_attrs %{attachment: "some content"}
  @invalid_attrs %{}

  # test "changeset with valid attributes" do
  #   changeset = OpportunityAttachment.changeset(%OpportunityAttachment{}, @valid_attrs)
  #   assert changeset.valid?
  # end

  test "changeset with invalid attributes" do
    changeset = OpportunityAttachment.changeset(%OpportunityAttachment{}, @invalid_attrs)
    refute changeset.valid?
  end
end
