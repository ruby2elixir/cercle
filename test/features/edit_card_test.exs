defmodule CercleApi.EditCardTest do
  use CercleApi.FeatureCase
  alias CercleApi.Card
  setup %{session: session} do
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

    url = "/company/#{company.id}/board/#{board.id}"
    session
    |> sign_in(user.login, "1234")
    {:ok,
     session: session, user: user, company: company,
     board: board, url: url, card: card
    }
  end

  test "Edit title card", %{session: session, url: url} do

    session
    |> visit_to_card(url)
    |> fill_in(css(".card-title-input-block > textarea"), with: "Update Card Title")
    |> click(css(".card-description > div"))
    |> assert_has(css("body.async-ready"))
    |> visit(url)
    |> assert_has(css("#board_columns", text: "Update Card Title"))
  end

  test "Edit description card", %{session: session, url: url} do
    session
    |> visit_to_card(url)
    |> find(css(".card-description"), fn(b) ->
      b
      |> click(css("div.card-description-rendering"))
      |> fill_in(css("textarea"), with: "Update Card Desc")
      |> click(button("Save"))
    end)
    |> assert_has(css("body.async-ready"))
    |> visit_to_card(url)
    |> assert_has(css(".card-description", text: "Update Card Desc"))
  end

  test "Add due date to card", %{session: session, url: url, card: card} do
    session
    |> visit_to_card(url)
    |> refute_has(css(".card-due-date"))
    |> click(button("ADD DUE DATE"))
    |> assert_has(css("body.async-ready"))
    |> find(css(".due-date-modal"), fn(modal) ->
      modal
      |> click(css("td", text: "Today"))
      |> click(css("[placeholder='Select time']"))
      |> fill_in(css("[placeholder='Select time']"), with: "23:00:00")
      |> click(button("Save"))
    end)
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".card-due-date"))

    refresh_card = Repo.get(Card, card.id)
    assert Timex.format!(refresh_card.due_date, "%F %T", :strftime) ==
      Timex.format!(Timex.today, "%F 22:00:00", :strftime)
  end

  defp visit_to_card(session, url) do
    session
    |> visit(url)
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
  end
end
