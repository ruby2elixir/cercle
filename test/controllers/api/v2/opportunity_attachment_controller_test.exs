defmodule CercleApi.APIV2.OpportunityAttachmentControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{Contact, Opportunity}

  setup %{conn: conn} do
    user = insert(:user)
    organization = insert(:organization, company: user.company, user: user  )
    contact = insert(:contact, company: user.company,
      organization: organization, user: user )
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

  test "GET index/2 should return attachments of opportunity", state do

  end

  test "POST create/2 create attachment of opportunity", state do

  end

  test "DELETE delete/2 create attachment of opportunity", state do

  end
end
