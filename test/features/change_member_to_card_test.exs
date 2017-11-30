defmodule CercleApi.ChangeMemberToCardCardTest do
  use CercleApi.FeatureCase


  test "Change member of a card", %{session: session} do
    {user, company} = create_user_with_company()
    user2 = CercleApi.Factory.insert(:user, full_name: "Test User2")
    add_company_to_user(user2, company)

    board = CercleApi.Factory.insert(:board, company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: user,
      company: company, board: board, board_column: board_column
    )

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".manager", text: user.full_name))
    |> click(css(".card-select-member > span > span", text: "CHANGE MEMBER"))
    |> click(css(".card-select-member ul.users-list li", text: user2.full_name))
    |> assert_has(css("body.async-ready"))
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".manager", text: user2.full_name))
  end
end
