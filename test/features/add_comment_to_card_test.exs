defmodule CercleApi.AddCommentToCardTest do
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
    |> find(css(".message-block"), fn(block) ->
      block
      |> fill_in(css("textarea"), with: "First Test Comment")
      |> click(button("Send"))
    end)
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".contact-page-events", text: "First Test Comment"))
  end
end
