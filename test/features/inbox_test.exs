defmodule CercleApi.InboxTest do
  use CercleApi.FeatureCase
  alias CercleApi.Factory
  use Timex

  setup %{session: session} do
    {user, company} = create_user_with_company()
    user2 = CercleApi.Factory.insert(:user,
      username: "Test2 User2",
      full_name: "test2",
      login: "test2@test.com",
      password: "1234",
      password_hash: "$2b$12$uYVXG6Fm6Tl/1zLMKW1u0uFnM41HB96imoOyxzKHfeyFB69zeAD8W"
    )
    add_company_to_user(user2, company)

    board = Factory.insert(:board, company: company, name: "Test Board 42")
    board_column = Factory.insert(:board_column, board: board)
    Factory.insert(:card,
      name: "Test Card 42", user: user, company: company,
      board: board, board_column: board_column
    )

    Factory.insert(:card,
      name: "Test Card 43", user: user2, company: company,
      board: board, board_column: board_column
    )

    Factory.insert(:activity,
      user: user, company: company, title: "Task#42", due_date: Timex.now()
    )
    conn = session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/activity")

    {:ok, session: conn, user: user, user2: user2, company: company}
  end

  test "List Activity and Cards", %{session: session} do
    session
    |> assert_has(css("body.async-ready"))
    |> assert_has(css("h3", text: "Cards assigned"))
    |> assert_has(css(".card-list .panel-heading", text: "Test Board 42"))
    |> assert_has(css("span.card-name", text: "Test Card 42"))
    |> assert_has(css("h3", text: "Tasks with due date"))
    |> assert_has(css("span.activity-name", text: "Task#42"))
  end

  test "Change assigned user", %{session: session} do
    session
    |> assert_has(css("body.async-ready"))
    |> assert_has(css("h3", text: "Cards assigned"))
    |> assert_has(css(".card-list .panel-heading", text: "Test Board 42"))
    |> assert_has(css("span.card-name", text: "Test Card 42"))
    |> assert_has(css("h3", text: "Tasks with due date"))
    |> assert_has(css("span.activity-name", text: "Task#42"))
    |> click(css("label.assigned-user"))
    |> click(css("ul.users-list li", text: "test2"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css("span.card-name", text: "Test Card 43"))
    |> take_screenshot
  end
end
