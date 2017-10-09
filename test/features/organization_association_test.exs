defmodule CercleApi.OrganizationAssociationTest do
  use CercleApi.FeatureCase
  test "Add organization to contact", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board,
      name: "Test Board", company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    contact = CercleApi.Factory.insert(:contact,
      first_name: "TestContact", last_name: "10",
      organization: nil,
      company: company, user: user)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: nil,
      contact_ids: [contact.id],
      company: company,board: board, board_column: board_column
    )
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))

    |> click(css(".add-organization", text: "Click to add" ))
    |> fill_in(css(".organization-select-modal input[type='search']"), with: "New Company" )
    |> click(css(".organization-select-modal .search-list .add-new", text: "Add: New Company" ))
    |> click(css(".organization-select-modal .save", text: "Save" ))
    |> assert_has(css(".attribute-value", text: "New Company"))
  end

  test "Remove organization from contact", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board,
      name: "Test Board", company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    organization = CercleApi.Factory.insert(:organization,
      name: "Test Org",
      company: company)
    contact = CercleApi.Factory.insert(:contact,
      first_name: "TestContact", last_name: "10",
      organization: organization,
      company: company, user: user)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: nil,
      contact_ids: [contact.id],
      company: company,board: board, board_column: board_column
    )
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".attribute-value", text: "Test Org"))
    |> click(css(".active-contact-info .remove-organization"))
    |> assert_has(css(".add-organization", text: "Click to add" ))
  end

  test "Change organization for contact", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board,
      name: "Test Board", company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    organization = CercleApi.Factory.insert(:organization,
      name: "Test Org",
      company: company)
    contact = CercleApi.Factory.insert(:contact,
      first_name: "TestContact", last_name: "10",
      organization: organization,
      company: company, user: user)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: nil,
      contact_ids: [contact.id],
      company: company,board: board, board_column: board_column
    )
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css(".attribute-value", text: "Test Org"))
    |> click(css(".active-contact-info .remove-organization"))
    |> click(css(".add-organization", text: "Click to add" ))
    |> fill_in(css(".organization-select-modal input[type='search']"), with: "New Company" )
    |> click(css(".organization-select-modal .search-list .add-new", text: "Add: New Company" ))
    |> click(css(".organization-select-modal .save", text: "Save" ))
    |> assert_has(css(".attribute-value", text: "New Company"))
  end

  test "Update organization details of contact", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board,
      name: "Test Board", company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)
    organization = CercleApi.Factory.insert(:organization,
      name: "Test Org",
      company: company)
    contact = CercleApi.Factory.insert(:contact,
      first_name: "TestContact", last_name: "10",
      organization: organization,
      company: company, user: user)
    CercleApi.Factory.insert(:card,
      name: "Test Card",
      user: nil,
      contact_ids: [contact.id],
      company: company,board: board, board_column: board_column
    )
    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> assert_has(css("body.async-ready"))
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css(".organization-name", text: "Test Org"))
    |> click(css(".organization-name", text: "Test Org"))
    |> fill_in(css(".organization-name input[type='text']"), with: "Test Org updated" )
    |> click(css(".organization-name button", text: "Save" ))
    |> assert_has(css(".organization-name", text: "Test Org updated"))

    |> assert_has(css(".organization-website > span", text: "Click to add"))
    |> click(css(".organization-website > span", text: "Click to add"))
    |> fill_in(css(".organization-website input[type='text']"), with: "http://example.org" )
    |> click(css(".attribute-value button", text: "Save" ))
    |> assert_has(css(".organization-website > span", text: "http://example.org"))

    |> visit("/company/#{company.id}/board/#{board.id}")
    |> assert_has(css("body.async-ready"))
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css(".organization-name", text: "Test Org updated"))
    |> assert_has(css(".organization-website > span", text: "http://example.org"))
  end
end
