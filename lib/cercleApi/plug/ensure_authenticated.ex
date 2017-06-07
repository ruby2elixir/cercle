defmodule CercleApi.Plug.EnsureAuthenticated do
  def init(opts \\ %{}), do: Enum.into(opts, %{})
  def call(conn, opts) do
    key = Map.get(opts, :key, :default)
    if Guardian.Plug.authenticated?(conn, key) do
      Guardian.Plug.EnsureAuthenticated.call(conn,
        Guardian.Plug.EnsureAuthenticated.init(opts))
    else
      case ExOauth2Provider.Plug.get_current_access_token(conn, key) do
        {:ok, _} ->
          ExOauth2Provider.Plug.EnsureAuthenticated.call(conn,
            ExOauth2Provider.Plug.EnsureAuthenticated.init(opts))
        _ ->
          Guardian.Plug.EnsureAuthenticated.call(conn,
            Guardian.Plug.EnsureAuthenticated.init(opts))
      end
    end
  end
end
