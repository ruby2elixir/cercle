defmodule CercleApi.Plug do
  @moduledoc """
  CercleApi.Plug contains functions that assist with interacting with
  CercleApi via Plugs.

  CercleApi.Plug is not itself a plug.

  Use the helpers to look up current_user.
  """
  def current_user(conn, the_key \\ :default) do
    Guardian.Plug.current_resource(conn, the_key) ||
      ExOauth2Provider.Plug.current_resource_owner(conn, the_key)
  end
end
