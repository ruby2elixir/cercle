defmodule CercleApi.APIV2.SessionView do
  use CercleApi.Web, :view

  def render("show.json", %{user: user}) do
    %{data: render_one(user, CercleApi.APIV2.UserView, "user.json")}
  end

  def render("login_error.json", _params) do
    %{message: "Incorrect login/password"}
  end
end
