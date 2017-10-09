defmodule CercleApi.SignUpTest do
  use CercleApi.FeatureCase, async: true

  test "GET /register", %{session: session} do
    session
    |> visit("/register")
    |> assert_has(css(".login-box-msg", text: "Get started free"))
    |> assert_has(css("form", action: "/register"))
  end

  test "Siginig up with correct data", %{session: session} do
    session
    |> visit("/register")
    |> find(css("form"), fn(form) ->
      form
      |> fill_in(text_field("Your Name"), with: "Jimm")
      |> fill_in(text_field("Name of your Company"), with: "Pequod")
      |> fill_in(text_field("Email"), with: "jimm@test.com")
      |> fill_in(text_field("Password"), with: "123456")
      |> click(button("Sign up"))
    end)

    assert current_url(session)  =~ ~r/\/company\/\d+\/board/
  end


  test "Siginig up with incorrect data", %{session: session} do
    user = create_user()
    company = CercleApi.Factory.insert(:company)
    add_company_to_user(user, company)

    session
    |> visit("/register")
    |> find(css("form"), fn(form) ->
      form
      |> fill_in(text_field("Your Name"), with: "Jimm")
      |> fill_in(text_field("Name of your Company"), with: "Pequod")
      |> fill_in(text_field("Email"), with: "test@test.com")
      |> fill_in(text_field("Password"), with: "123456")
      |> click(button("Sign up"))
    end)

    assert current_url(session) == "http://localhost:4001/register"
    session
    |> assert_has(css(".alert", text: "Login has already been taken"))
  end
end
