defmodule CercleApi.TestHelpers do
  import CercleApi.Factory
  alias CercleApi.Repo
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

  def attach_file(model, rec, attr, file) do
    attachment_attrs = %{
      attr => %Plug.Upload{ path: file, filename: Path.basename(file) }
    }

    rec
    |> model.changeset(attachment_attrs)
    |> Repo.update!
  end

  def add_company_to_user(user, company) do
    insert(:user_company, company_id: company.id, user_id: user.id)
  end

  def add_company_to_user(user) do
    insert(:user_company, company_id: insert(:company).id, user_id: user.id)
  end
end
