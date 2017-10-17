defmodule CercleApi.AddTaskToCardTest do
  use CercleApi.FeatureCase
  alias CercleApi.Activity

  test "Add Task", %{session: session} do
    {user_with_company, company} = create_user_with_company()

    user = user_with_company
    |> Ecto.Changeset.change(time_zone: "Europe/Paris")
    |> Repo.update!
    board = CercleApi.Factory.insert(:board, company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    card = CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: user, company: company, board: board, board_column: board_column
    )

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> click(button("Add a task..."))
    |> assert_has(css(".card-to-dos"))
    |> assert_has(css(".todo-title", text: "Title"))
    |> click(css(".todo-assigment-placeholder-text"))
    |> find(css(".input-modal.assignment-modal"), fn(modal) ->
      modal
      |> click(css("td", text: "Today"))
      |> click(css("[placeholder='Select time']"))
      |> fill_in(css("[placeholder='Select time']"), with: "20:00:00")
      |> click(button("Save"))
    end)
    |> assert_has(css("body.async-ready"))
    task = Repo.get_by(Activity, card_id: card.id)
    assert Timex.format!(task.due_date, "%F %T", :strftime) ==
      Timex.format!(Timex.today, "%F 18:00:00", :strftime)
  end
end
