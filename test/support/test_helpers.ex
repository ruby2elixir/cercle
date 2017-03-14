defmodule CercleApi.TestHelpers do

  alias CercleApi.Repo

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
          login:    "user#{Base.encode16(:crypto.strong_rand_bytes(8))}@email.com",
          name:     "name",
          password: "supersecret",
                     }, Enum.into(attrs, %{}))

    %CercleApi.User{}
      |> CercleApi.User.registration_changeset(changes)
      |> Repo.insert!()
  end

  def insert_company() do
    {_, company} = Repo.insert(%CercleApi.Company{title: "Coca-Cola Inc."})
    company
  end

  use Phoenix.ConnTest

  @endpoint CercleApi.Endpoint

  def guardian_login(conn, user, token \\ :token, opts \\ []) do
    conn
    |> bypass_through(CercleApi.Router, [:browser])
    |> get("/")
    |> Guardian.Plug.sign_in(user, token, opts)
    |> send_resp(200, "Flush the session yo")
    |> recycle()
  end

end