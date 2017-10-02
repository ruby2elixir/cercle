defmodule CercleApi.IntegrationHelpers do
  import Wallaby.Query
  use Wallaby.DSL

  def sign_in(session, login, password \\ "1234") do
     session
     |> visit("/login")
     |> find(css("form"), fn(form) ->
       form
       |> fill_in(text_field("login"), with: login)
       |> fill_in(text_field("password"), with: password)
       |> click(button("Sign In"))
     end)
  end
end
