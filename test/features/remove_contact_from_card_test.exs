defmodule CercleApi.RemoveContactFromCardTest do
  use CercleApi.FeatureCase

  test "Add exist contact to card", %{session: session} do
    {user, company} = create_user_with_company()
    board = CercleApi.Factory.insert(:board, company: company)
    board_column = CercleApi.Factory.insert(:board_column, board: board)

    c1 = CercleApi.Factory.insert(:contact,
      first_name: "Jime", last_name: "Hendrix",
      company: company, user: user)

    c2 = CercleApi.Factory.insert(:contact,
      first_name: "Tim", last_name: "Burton",
      company: company, user: user)


    CercleApi.Factory.insert(:card,
      name: "Test Card", user: nil, contact_ids: [c1.id, c2.id],
      company: company, board: board, board_column: board_column
    )

    accept_confirm_script = "window.confirm = function(msg) { return true; }"

    session
    |> sign_in(user.login, "1234")
    |> visit("/company/#{company.id}/board/#{board.id}")
    |> click(css("span.name", text: "Test Card"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css("span.contact", text: "Jime Hendrix"))
    |> assert_has(css("span.contact", text: "Tim Burton"))
    |> click(css("span.contact", text: "Tim Burton" ))
    |> execute_script(accept_confirm_script)
    |> click(css("span.active a.remove"))
    |> assert_has(css("body.async-ready"))
    |> assert_has(css("span.contact", text: "Jime Hendrix"))
    |> refute_has(css("span.contact", text: "Tim Burton"))
  end
end
