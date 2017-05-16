defmodule CercleApi.APIV2.CardControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{Contact,Card, CardAttachment}

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

  test "try to delete authorized Card", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Card.changeset(%Card{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id})
    card = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/card/#{card.id}"
    assert json_response(conn, 200)
  end

  test "try to delete unauthorized Card", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Card.changeset(%Card{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id + 1})
    card = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/card/#{card.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to update authorized Card", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Card.changeset(%Card{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id})
    card = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/card/#{card.id}", card: %{name: "Modified Card"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized Card", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Card.changeset(%Card{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id + 1})
    card = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/card/#{card.id}", card: %{name: "Modified Card"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "deleting card should delete attachments", state do
    contact = Repo.get!(Contact, state[:contact].id)
    |> Repo.preload([:organization])
    changeset = Card.changeset(%Card{}, %{name: contact.organization.name <> " / " <> state[:board].name, board_column_id: state[:board_column].id, board_id: state[:board].id, contact_ids: [state[:contact].id], main_contact_id: state[:contact].id, user_id: state[:user].id , company_id: state[:company].id})
    card = Repo.insert!(changeset)

    attachment =  CardAttachment
    |> attach_file(insert(:card_attachment, card: card),
    :attachment, "test/fixtures/logo.png")

    conn = delete state[:conn], "/api/v2/card/#{card.id}"
    assert json_response(conn, 200)

    # Ensure attachment is deleted
    attachment = Repo.get(CardAttachment, attachment.id)
    assert attachment == nil
  end

end
