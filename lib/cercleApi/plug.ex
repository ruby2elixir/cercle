defmodule CercleApi.Plug do
  def current_user(conn, the_key \\ :default) do
    Guardian.Plug.current_resource(conn, the_key) ||
      ExOauth2Provider.Plug.current_resource_owner(conn, the_key)
  end
end
