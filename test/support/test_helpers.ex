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

  def insert_organization(attrs \\ %{}) do
    organization_params = Map.merge(%{name: "Org1"}, Enum.into(attrs, %{}))
    %CercleApi.Organization{}
      |> CercleApi.Organization.changeset(organization_params)
      |> Repo.insert!()
  end

  def insert_contact(attrs \\ %{}) do
    contact_params = Map.merge(%{name: "TestContact1"}, Enum.into(attrs, %{}))
    %CercleApi.Contact{}
      |> CercleApi.Contact.changeset(contact_params)
      |> Repo.insert!()
  end

  def insert_board(attrs \\ %{}) do
    board_params = Map.merge(%{name: "TestBoard1"}, Enum.into(attrs, %{}))
    %CercleApi.Board{}
      |> CercleApi.Board.changeset(board_params)
      |> Repo.insert!()
  end

  def insert_board_column(attrs \\ %{}) do
    board_col_params = Map.merge(%{name: "Step1", order: "1"}, Enum.into(attrs, %{}))
    %CercleApi.BoardColumn{}
      |> CercleApi.BoardColumn.changeset(board_col_params)
      |> Repo.insert!()
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


  def render_json(view, template, assigns) do
    view.render(template, assigns) |> format_json
  end

  defp format_json(data) do
    data |> Poison.encode! |> Poison.decode!
  end
end
