defmodule CercleApi.Plug.CurrentUser do
  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = conn
    |> CercleApi.Plug.current_user
    Plug.Conn.assign(conn, :current_user, current_user)
  end
end
