defmodule CercleApi.AddFileToCardTest do
  use CercleApi.FeatureCase

  test "Add comment", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board, company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: user, company: company, board: board, board_column: board_column
    )

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))

    |> attach_file(css("input[name='attachment']", visible: false), path: "test/fixtures/logo.png")
    |> click(css("label", text: "UPLOAD FILE"))
    |> assert_has(css("body.async-ready"))
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css(".attach-item", text: "Download"))
  end
end
