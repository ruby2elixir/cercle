defmodule CercleApi.APIV2.BoardColumnControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{BoardColumn}

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    board = insert(:board, company: company)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, company: company, user: user, board: board}
  end

  test "create authorized board column for board with valid params", state do
    conn = post state[:conn], "/api/v2/board_column", board_column: %{name: "Step1", order: "1", board_id: state[:board].id}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "create board column for invalid board with valid params", state do
    conn = post state[:conn], "/api/v2/board_column", board_column: %{name: "Step1", order: "1", board_id: state[:board].id + 1}
    assert json_response(conn, 200)["error"] == "Resource not found!"
  end

  test "create board column for unauthorized board with valid params", state do
    board = insert(:board)
    conn = post state[:conn], "/api/v2/board_column", board_column: %{name: "Step1", order: "1", board_id: board.id}
    assert json_response(conn, 200)["error"] == "You are not authorized for this action!"
  end


  test "try to update authorized board column for board", state do
    changeset = BoardColumn.changeset(%BoardColumn{}, %{name: "Step1", order: "1", board_id: state[:board].id})
    board_column = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/board_column/#{board_column.id}", board_column: %{name: "ModifiedName"}
    assert json_response(conn, 200)["data"]["name"] == "ModifiedName"
  end

  test "try to update unauthorized board column for board", state do
    board = insert(:board)
    changeset = BoardColumn.changeset(%BoardColumn{}, %{name: "Step1", order: "1", board_id: board.id})
    board_column = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/board_column/#{board_column.id}", board_column: %{name: "ModifiedName"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

  test "try to delete authorized board column for board", state do
    changeset = BoardColumn.changeset(%BoardColumn{}, %{name: "Step1", order: "1", board_id: state[:board].id})
    board_column = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/board_column/#{board_column.id}"
    assert json_response(conn, 200)
  end

  test "try to delete unauthorized board column for board", state do
    board = insert(:board)
    changeset = BoardColumn.changeset(%BoardColumn{}, %{name: "Step1", order: "1", board_id: board.id})
    board_column = Repo.insert!(changeset)
    conn = delete state[:conn], "/api/v2/board_column/#{board_column.id}"
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

end
