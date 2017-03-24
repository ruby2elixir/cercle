defmodule CercleApi.APIV2.BoardColumnControllerTest do
  use CercleApi.ConnCase
  alias CercleApi.{User,Contact,Board,BoardColumn}

  setup %{conn: conn} do
    company = insert_company()
    user = insert_user(username: "test", company_id: company.id)
    board = insert_board(company_id: company.id)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, board: board}
  end

  test "create board column for board on post", state do
    conn = post state[:conn], "/api/v2/board_column", board_column: %{name: "Step1", order: "1", board_id: state[:board].id}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "update board column for board on PUT", state do
    changeset = BoardColumn.changeset(%BoardColumn{}, %{name: "Step1", order: "1", board_id: state[:board].id})
    board_column = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/board_column/#{board_column.id}", boardColumn: %{name: "ModifiedName"}
    assert json_response(conn, 200)["data"]["name"] == "ModifiedName"
  end

  test "delete board column for board on DELETE", state do
    changeset = BoardColumn.changeset(%BoardColumn{}, %{name: "Step1", order: "1", board_id: state[:board].id})
    board_column = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/board_column/#{board_column.id}"
    assert json_response(conn, 200)
  end


end
