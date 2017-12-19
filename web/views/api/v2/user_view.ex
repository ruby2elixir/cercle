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
      full_name: user.full_name,
      login: user.login,
      created_at: user.inserted_at,
      name: user.username,
      profile_image_url: CercleApi.UserProfileImage.url({user.profile_image, user}, :small)
    }
  end
end
