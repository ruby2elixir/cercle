defmodule CercleApi.EditCardTest do
  use CercleApi.FeatureCase

  setup %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board, company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: user, company: company, board: board, board_column: board_column
    )

    url = "/company/#{company.id}/board/#{board.id}"
    session
    |> sign_in(user.login, "1234")
    {:ok,
     session: session, user: user, company: company,
     board: board, url: url
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

  test "Add due date to card", %{session: session, url: url} do
    session
    |> visit_to_card(url)
    |> refute_has(css(".card-due-date"))
    |> click(button("ADD DUE DATE"))
    |> assert_has(css("body.async-ready"))
    |> find(css(".due-date-modal"), fn(modal) ->
      modal
      |> click(css("td", text: "Today"))
      |> click(button("Save"))
    end)
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".card-due-date"))
  end

  defp visit_to_card(session, url) do
    session
    |> visit(url)
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
  end
end
