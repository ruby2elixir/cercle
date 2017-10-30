defmodule CercleApi.NewBoardTest do
  use CercleApi.FeatureCase, async: true

  test "Add new board", %{session: session} do
    user = create_user()
    user_company = CercleApi.Factory.insert(:company)
    add_company_to_user(user, user_company)

    session
    |> sign_in(user.login, "1234")
    |> click(css(".add-board"))
    |> fill_in(css(".board_name"), with: "Test Board")
    |> click(button("CREATE"))
    |> visit("/company/#{user_company.id}/board")
    |> assert_has(css(".board-list-app", text: "Test Board"))
  end
end
