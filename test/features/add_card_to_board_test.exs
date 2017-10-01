defmodule CercleApi.AddCardToBoardTest do
  use CercleApi.FeatureCase, async: true
  setup %{session: session} do
    user = create_user()
    company = CercleApi.Factory.insert(:company)
    add_company_to_user(user, company)
    board = CercleApi.Factory.insert(:board,
      name: "Test Board", company: company)
    CercleApi.Factory.insert(:board_column, board: board)
    {:ok, session: session, user: user, company: company, board: board}
  end

  test "Add new card without contact", %{
    session: session, user: user, company: company, board: board} do
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css(".add-card"))
    |> fill_in(text_field("Name of the Card"), with: "Test Card")
    |> find(css(".new-card-form"), fn(form) -> click(form, button("Save")) end)
    |> assert_has(css("body.async-ready"))
    |> refute_has(css(".new-card-form"))
    |> assert_has(css("#board_columns", text: "Test Card"))
  end

  test "Add new card with contact", %{
    session: session, user: user, company: company, board: board} do
    CercleApi.Factory.insert(:contact,
      first_name: "Test", last_name: "Contact",
      user: user, company: company)

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css(".add-card"))
    |> fill_in(text_field("Name of the Card"), with: "Test Card")
    |> find(css(".add-contact"), fn(contact_form) ->
      contact_form
      |> fill_in(css("input[type='search']"), with: "Test")
      |> click(css(".dropdown-menu a", text: "Test Contact" ))
    end)
    |> find(css(".new-card-form"), fn(form) -> click(form, button("Save")) end)
    |> assert_has(css("body.async-ready"))
    |> refute_has(css(".new-card-form"))
    |> assert_has(css("#board_columns", text: "Test Card - Test Contact"))
  end

end
