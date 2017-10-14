defmodule CercleApi.AddCardToBoardTest do
  use CercleApi.FeatureCase
  setup %{session: session} do
    {user, company} = create_user_with_company()
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
    |> assert_has(css("#board_columns", text: "Test Contact - Test Card"))
  end

  test "Cancel should reset new card", %{
    session: session, user: user, company: company, board: board} do
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css(".add-card"))
    |> fill_in(text_field("Name of the Card"), with: "Test Card")
    |> fill_in(css("input[type='search']"), with: "New contact")
    |> click(css(".dropdown-menu a", text: "New contact" ))
    |> fill_in(css("input[type=email]"), with: "abc@xyz.com")
    |> fill_in(css("input[type=phone]"), with: "123456789")
    |> click(css(".new-card-form .btn-link", text: "Cancel" ))
    |> click(css(".add-card"))
    |> assert_has(css("input.card-name", with: ""))
    |> assert_has(css("input[type=email]", with: ""))
    |> assert_has(css("input[type=phone]", with: ""))
  end
end
