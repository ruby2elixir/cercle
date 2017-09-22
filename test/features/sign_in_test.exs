defmodule CercleApi.SignInTest do
  use CercleApi.FeatureCase, async: true

  import Wallaby.Query#, only: [css: 2, css: 1]

  test "GET /login", %{session: session} do
    session
    |> visit("/login")
    |> assert_has(css(".login-box-msg", text: "Please type your credentials"))
    |> assert_has(css("form", action: "/login"))
  end

  test "Sign in with wrong email/password", %{session: session} do
    session
    |> visit("/login")
    |> find(css("form", action: "/login"), fn(form) ->
      form
      |> fill_in(text_field("login"), with: "testLogin")
      |> click(button("Sign In"))
    end)
    |> assert_has(css(".alert", text: "Invalid username/password combination"))

  end

  test "Sign in with existing email/password", %{session: session} do
    user = CercleApi.Factory.insert(:user,
      login: "testuser",
      password: "1234",
      password_hash: "$2b$12$uYVXG6Fm6Tl/1zLMKW1u0uFnM41HB96imoOyxzKHfeyFB69zeAD8W")
    company = CercleApi.Factory.insert(:company)
    CercleApi.Factory.insert(:user_company,
      company_id: company.id,
      user_id: user.id)
    session
    |> visit("/login")
    |> find(css("form"), fn(form) ->
      form
      |> fill_in(text_field("login"), with: "testuser")
      |> fill_in(text_field("password"), with: "1234")
      |> click(button("Sign In"))

    end)

    assert current_url(session) == "http://localhost:4001/company/#{company.id}/board"
  end
end
