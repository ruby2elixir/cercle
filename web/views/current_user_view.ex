defmodule CercleApi.CurrentUserView do
  use CercleApi.Web, :view


  def render("show.json", %{ token: token, user: user}) do
    %{token: token, user: user}
  end

  def render("forbidden.json", %{ error: error}) do
    %{error: error }
  end

end
