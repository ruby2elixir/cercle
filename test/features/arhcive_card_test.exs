defmodule CercleApi.ArchiveCardTest do
  use CercleApi.FeatureCase

  test "Archive card", %{session: session} do
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
    |> click(button("ARCHIVE"))
    |> assert_has(css("body.async-ready"))
    |> click(css(".card-modal button.close"))
    |> assert_has(css("body.async-ready"))
    |> refute_has(css("#board_columns", text: "Test Card"))
  end
end
