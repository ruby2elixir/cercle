defmodule CercleApi.BoardSidebarTest do
  use CercleApi.FeatureCase
  setup %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board,
      name: "Test Board", company: company)
    column = CercleApi.Factory.insert(:board_column, board: board)
    card = CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: user, company: company, board: board, board_column: column
    )
    {:ok, session: session, user: user, company: company, board: board, card: card}
  end

  test "Add new card without contact", %{
    session: session, user: user, company: company, board: board, card: card } do
    CercleApi.Factory.insert(:timeline_event,
      company: company, card: card, user: user,
      content: "please check the video",
      event_name: "comment"
    )

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/")
    |> click(css("a", text: "Test Board"))
    |> click(css("a", text: "Show Menu"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".comment-message", text: "please check the video"))
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("a", text: "Show Menu"))
    |> assert_has(css(".comment-message", text: "please check the video"))
  end
end
