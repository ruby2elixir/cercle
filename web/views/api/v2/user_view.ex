defmodule CercleApi.APIV2.UserView do
  use CercleApi.Web, :view

  def render("index.json", %{users: users}) do
    %{data: render_many(users, CercleApi.APIV2.UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, CercleApi.APIV2.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{id: user.id,
      user_name: user.user_name,
      login: user.login,
      email: user.emails,
      created_at: user.inserted_at,
      name: user.name}
  end

  def render("organizations.json", %{organizations: organizations}) do
    organizations
  end
end
