defmodule CercleApi.APIV2.UserController do
  use CercleApi.Web, :controller

  alias CercleApi.User
  alias CercleApi.Company

  plug Guardian.Plug.EnsureAuthenticated

  plug :scrub_params, "user" when action in [:create, :update]

end
