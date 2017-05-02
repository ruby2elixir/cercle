defmodule CercleApi.APIV2.OpportunityControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{Contact,Opportunity, OpportunityAttachment}

  setup %{conn: conn} do
    user = insert(:user)
    organization = insert(:organization,
      company: user.company, user: user
    )
    contact = insert(:contact,
      company: user.company, organization: organization, user: user
    )
    board = insert(:board, company: user.company)
    board_column = insert(:board_column, board: board)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {
      :ok, conn: conn,
      user: user, organization: organization,
      contact: contact, company: user.company,
      board: board, board_column: board_column
    }
  end

  test "try to delete authorized Opportunity", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Opportunity.changeset(%Opportunity{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id})
    opportunity = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/opportunity/#{opportunity.id}"
    assert json_response(conn, 200)
  end

  test "try to delete unauthorized Opportunity", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Opportunity.changeset(%Opportunity{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id + 1})
    opportunity = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/opportunity/#{opportunity.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to update authorized Opportunity", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Opportunity.changeset(%Opportunity{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id})
    opportunity = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/opportunity/#{opportunity.id}", opportunity: %{name: "Modified Opportunity"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized Opportunity", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Opportunity.changeset(%Opportunity{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id + 1})
    opportunity = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/opportunity/#{opportunity.id}", opportunity: %{name: "Modified Opportunity"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "deleting opportunity should delete attachments", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Opportunity.changeset(%Opportunity{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id})
    opportunity = Repo.insert!(changeset)

    attachment =  OpportunityAttachment
    |> attach_file(insert(:opportunity_attachment, opportunity: opportunity),
    :attachment, "test/fixtures/logo.png")

    conn = delete state[:conn], "/api/v2/opportunity/#{opportunity.id}"
    assert json_response(conn, 200)

    # Ensure attachment is deleted
    attachment = Repo.get(OpportunityAttachment, attachment.id)
    assert attachment == nil
  end

end
