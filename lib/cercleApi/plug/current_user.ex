defmodule CercleApi.Plug.CurrentUser do
  def init(opts), do: opts

  def call(conn, _opts) do
    current_user = CercleApi.Plug.current_user(conn)
    Plug.Conn.assign(conn, :current_user, current_user)
  end
end
