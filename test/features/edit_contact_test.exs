defmodule CercleApi.EditContactTest do
  use CercleApi.FeatureCase

  test "Edit name of contact", %{session: session} do
    {user, company} = create_user_with_company()
    CercleApi.Factory.insert(:contact,
      first_name: "TestContact", last_name: "1",
      email: "test@test.com",
      company: company, user: user)

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/contact")
    |> click(css("td", text: "TestContact 1"))
    |> click(css(".contact-modal span.full-name", text: "TestContact 1"))
    |> fill_in(css(".name-edit-modal input.fname"), with: "Jimi")
    |> fill_in(css(".name-edit-modal input.lname"), with: "Hendrix")
    |> click(button("Save"))
    |> assert_has(css(".contact-modal span.full-name", text: "Jimi Hendrix"))
    |> assert_has(css("td", text: "Jimi Hendrix"))
    |> take_screenshot
  end
end
