defmodule CercleApi.APIV2.BoardControllerTest do
  use CercleApi.ConnCase
  alias CercleApi.{Board}

  setup %{conn: conn} do
    company = insert_company()
    user = insert_user(username: "test", company_id: company.id)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: company}
  end

  test "create board with valid params", state do
    conn = post state[:conn], "/api/v2/board", board: %{name: "Board1", company_id: state[:company].id, user_id: state[:user].id}
    assert json_response(conn, 201)["data"]["id"]
  end

  test "try to update authorized board with valid params", state do
    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id, user_id: state[:user].id})
    board = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/board/#{board.id}", board: %{name: "Modified Board2"}
    assert json_response(conn, 200)["data"]["id"]
  end

  test "try to update unauthorized board", state do
    changeset = Board.changeset(%Board{}, %{name: "Board2", company_id: state[:company].id + 1, user_id: state[:user].id})
    board = Repo.insert!(changeset)
    conn = put state[:conn], "/api/v2/board/#{board.id}", board: %{name: "Modified Contact"}
    assert json_response(conn, 403)["error"] == "You are not authorized for this action!"
  end

end
