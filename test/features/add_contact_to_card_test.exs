defmodule CercleApi.AddContactToCardCardTest do
  use CercleApi.FeatureCase

  test "Add exist contact to card", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board, company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: nil,
      company: company, board: board, board_column: board_column
    )
    CercleApi.Factory.insert(:contact,
      first_name: "TestContact", last_name: "1",
      company: company, user: user)

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> click(button("ADD CONTACT"))
    |> assert_has(css(".add-contact"))
    |> fill_in(css(".add-contact input[type='search']"), with: "TestContact" )
    |> click(css(".dropdown-menu a", text: "TestContact 1" ))
    |> click(button("Add Contact"))
    |> assert_has(css("body.async-ready"))
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".card-contacts-list", text: "TestContact 1"))
  end


  test "Add new contact to card", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board, company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: nil,
      company: company, board: board, board_column: board_column
    )
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> click(button("ADD CONTACT"))
    |> assert_has(css(".add-contact"))
    |> fill_in(css(".add-contact input[type='search']"), with: "Jimi Hendrix" )
    |> click(css(".dropdown-menu a", text: "Jimi Hendrix" ))
    |> click(button("Add Contact"))
    |> assert_has(css("body.async-ready"))
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".card-contacts-list", text: "Jimi Hendrix"))
  end
end
