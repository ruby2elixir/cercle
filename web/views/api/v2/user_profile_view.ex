defmodule CercleApi.APIV2.UserProfileView do
  use CercleApi.Web, :view

  def render("show.json", %{user: user}) do
    user_json(user)
  end

  def user_json(user) do
    %{
      id: user.id,
      full_name: user.full_name,
      login: user.login,
      created_at: user.inserted_at,
      username: user.username,
      time_zone: user.time_zone,
      notification: user.notification,
      profile_image: nil,
      profile_image_url: CercleApi.UserProfileImage.url({user.profile_image, user}, :small)
    }
  end
end
