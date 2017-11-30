defmodule CercleApi.AddMemberToCardCardTest do
  use CercleApi.FeatureCase

  test "Add/remove member to card", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board, company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: nil,
      company: company, board: board, board_column: board_column
    )

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> refute_has(css(".manager", text: user.full_name))
    |> click(css(".card-select-member > span > span", text: "ADD MEMBER"))
    |> click(css(".card-select-member ul.users-list > li"))
    |> assert_has(css("body.async-ready"))
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".manager", text: user.full_name))
    |> click(css(".card-select-member > span > span", text: "CHANGE MEMBER"))
    |> click(css(".card-select-member ul.users-list > li"))
    |> refute_has(css(".manager", text: user.full_name))
  end
end
