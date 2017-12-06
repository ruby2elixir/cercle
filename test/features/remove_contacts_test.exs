defmodule CercleApi.RemoveContactsTest do
  use CercleApi.FeatureCase

  test "Remove contact", %{session: session} do
    {user, company} = create_user_with_company()

    c1 = CercleApi.Factory.insert(:contact,
      first_name: "Jime", last_name: "Hendrix",
      company: company, user: user)

    CercleApi.Factory.insert(:contact,
      first_name: "Tim", last_name: "Burton",
      company: company, user: user)

    accept_confirm_script = "window.confirm = function(msg) { return true; }"

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/contact/")
    |> execute_script(accept_confirm_script)
    |> click(css("tr.contact-row-#{c1.id} label.el-checkbox"))
    |> assert_has(css("button", text: "Delete contacts"))
    |> click(button("Delete contacts"))
    |> assert_has(css("body.async-ready"))
    |> refute_has(css("td", text: "Jime Hendrix"))
    |> assert_has(css("td", text: "Tim Burton"))
  end
end
