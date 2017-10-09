defmodule CercleApi.SignInTest do
  use CercleApi.FeatureCase, async: true

  test "GET /login", %{session: session} do
    session
    |> visit("/login")
    |> assert_has(css(".login-box-msg", text: "Sign in to Cercle"))
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
    user = create_user()
    company = CercleApi.Factory.insert(:company)
    add_company_to_user(user, company)
    session
    |> visit("/login")
    |> find(css("form"), fn(form) ->
      form
      |> fill_in(text_field("login"), with: "test@test.com")
      |> fill_in(text_field("password"), with: "1234")
      |> click(button("Sign In"))

    end)

    assert current_url(session) == "http://localhost:4001/company/#{company.id}/board"
  end
end
