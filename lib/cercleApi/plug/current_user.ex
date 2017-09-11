defmodule CercleApi.Plug.CurrentUser do
  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn
    |> CercleApi.Plug.current_user
    Plug.Conn.assign(conn, :current_user, user)
  end
end
