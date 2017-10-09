defmodule CercleApi.AddOrganizationToContact do
  use CercleApi.FeatureCase
  test "Add organization to contact", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board,
      name: "Test Board", company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    card = CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: nil,
      company: company, board: board, board_column: board_column
    )
    contact = CercleApi.Factory.insert(:contact,
      first_name: "TestContact", last_name: "1",
      company: company, user: user)
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> click(button("ADD CONTACT"))
    |> assert_has(css(".add-contact"))
    |> fill_in(css(".add-contact input[type='search']"), with: "TestContact 10" )
    |> click(css(".dropdown-menu a", text: "TestContact 10" ))
    |> click(button("Add Contact"))

    |> click(css(".add-organization", text: "Click to add" ))
    |> fill_in(css(".organization-select-modal input[type='search']"), with: "New Company" )
    |> click(css(".organization-select-modal .search-list .add-new", text: "Add: New Company" ))
    |> click(css(".organization-select-modal .save", text: "Save" ))


    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".attribute-value", text: "New Company"))
    |> click(css(".active-contact-info .remove-organization"))
    |> assert_has(css(".add-organization", text: "Click to add" ))

    |> click(css(".add-organization", text: "Click to add" ))
    |> fill_in(css(".organization-select-modal input[type='search']"), with: "New Company" )
    |> click(css(".organization-select-modal .search-list li h4", text: "New Company" ))
    |> click(css(".organization-select-modal .save", text: "Save" ))
  end
end
