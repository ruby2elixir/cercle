defmodule CercleApi.InviteToCompanyTest do
  use CercleApi.FeatureCase, async: true

  test "GET /register/:register_values/join/ - user signed", %{session: session} do
    user = create_user()
    user_company = CercleApi.Factory.insert(:company)
    add_company_to_user(user, user_company)
    company = CercleApi.Factory.insert(:company, title: "Test Company")
    code = %{"company_id": "#{company.id}", "email": "test@test.com"}
    |> Cipher.cipher
    |> URI.encode

    session
    |> visit("/login")
    |> find(css("form"), fn(form) ->
      form
      |> fill_in(text_field("login"), with: "test@test.com")
      |> fill_in(text_field("password"), with: "1234")
      |> click(button("Sign In"))
    end)
    |> visit("/register/#{code}/join/")
    |> visit("/company/#{company.id}/board")

    assert_has(session, css(".current-company", text: company.title))

  end

  test "GET /register/:register_values/join/ - new user", %{session: session} do
    company = CercleApi.Factory.insert(:company)
    code = %{"company_id": "#{company.id}", "email": "test@test.com"}
    |> Cipher.cipher
    |> URI.encode

    session
    |> visit("/register/#{code}/join/")
    |> find(css("form"), fn(form) ->
      form
      |> fill_in(text_field("Your Name"), with: "Jimm")
      |> fill_in(text_field("Password"), with: "123456")
      |> click(button("Sign Up"))
    end)
    |> assert_has(css(".current-company", text: company.title))
  end

  test "GET /register/:register_values/join/ - exist user", %{session: session} do
    user = create_user()
    user_company = CercleApi.Factory.insert(:company)
    add_company_to_user(user, user_company)
    company = CercleApi.Factory.insert(:company, title: "Test Company")
    code = %{"company_id": "#{company.id}", "email": "test@test.com"}
    |> Cipher.cipher
    |> URI.encode

    session
    |> visit("/register/#{code}/join/")
    |> click(link("Login"))
    |> find(css("form"), fn(form) ->
      form
      |> fill_in(text_field("login"), with: "test@test.com")
      |> fill_in(text_field("password"), with: "1234")
      |> click(button("Sign In"))
    end)
    |> assert_has(css(".current-company", text: company.title))
  end
end
