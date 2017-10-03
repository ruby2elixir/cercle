defmodule CercleApi.InviteToCompanyTest do
  use CercleApi.FeatureCase, async: true

  test "GET /register/:register_values/join/ - user signed", %{session: session} do
    {_user, _user_company} = create_user_with_company()
    company = CercleApi.Factory.insert(:company, title: "Test Company")
    code = %{"company_id": "#{company.id}", "email": "test@test.com"}
    |> encode_data

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
    |> encode_data

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

  test "GET /register/:register_values/join/ - new user (different email)", %{session: session} do
    company = CercleApi.Factory.insert(:company, title: "First Test Company")
    code = %{"company_id": "#{company.id}", "email": "test@test.com"}
    |> encode_data

    session
    |> visit("/register/#{code}/join/")
    |> find(css("form"), fn(form) ->
      form
      |> fill_in(text_field("Your Name"), with: "Jimm")
      |> fill_in(text_field("Email"), with: "test1@test.com")
      |> fill_in(text_field("Password"), with: "123456")
      |> click(button("Sign Up"))
    end)
    |> assert_has(css(".current-company", text: company.title))

    user = CercleApi.Repo.get_by(CercleApi.User, login: "test1@test.com")
    companies = CercleApi.Company.user_companies(user)
    refute Enum.member?(companies, company)
    assert length(companies) == 1
  end

  test "GET /register/:register_values/join/ - exist user", %{session: session} do
    {_user, _user_company} = create_user_with_company()
    company = CercleApi.Factory.insert(:company, title: "Test Company")
    code = %{"company_id": "#{company.id}", "email": "test@test.com"}
    |> encode_data

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

  defp encode_data(data) do
    data
    |> Cipher.cipher
    |> URI.encode
  end
end
