defmodule CercleApi.InboxTest do
  use CercleApi.FeatureCase
  alias CercleApi.Factory
  use Timex

  setup %{session: session} do
    {user, company} = create_user_with_company()
    board = Factory.insert(:board, company: company, name: "Test Board 42")
    board_column = Factory.insert(:board_column, board: board)
    Factory.insert(:card,
      name: "Test Card 42", user: user, company: company,
      board: board, board_column: board_column
    )

    Factory.insert(:activity,
      user: user, company: company, title: "Task#42", due_date: Timex.now()
    )
    {:ok, session: session, user: user, company: company}
  end

  test "List Activity and Cards", %{session: session, user: user, company: company} do
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/activity")
    |> assert_has(css("body.async-ready"))
    |> assert_has(css("h3", text: "Cards assigned to"))
    |> assert_has(css(".card-list .panel-heading", text: "Test Board 42"))
    |> assert_has(css("span.card-name", text: "Test Card 42"))
    |> assert_has(css("h3", text: "Tasks with due date"))
    |> assert_has(css("span.activity-name", text: "Task#42"))
    |> take_screenshot
  end
end
