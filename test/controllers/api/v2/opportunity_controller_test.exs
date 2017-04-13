defmodule CercleApi.APIV2.OpportunityControllerTest do
  use CercleApi.ConnCase
  alias CercleApi.{Contact,Opportunity}

  setup %{conn: conn} do
    company = insert_company()
    user = insert_user(username: "test", company_id: company.id)
    organization = insert_organization(company_id: company.id, user_id: user.id)
    contact = insert_contact(company_id: company.id, organization_id: organization.id , user_id: user.id)
    board = insert_board(company_id: company.id)
    board_column = insert_board_column(board_id: board.id)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, organization: organization, contact: contact, company: company, board: board, board_column: board_column}
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

end
