defmodule CercleApi.APIV2.OrganizationController do
  use CercleApi.Web, :controller

  alias CercleApi.Organization

  plug :scrub_params, "organization" when action in [:create, :update]

  def index(conn, _params) do
    organizations = Repo.all(Organization)
    render(conn, "index.json", organizations: organizations)
  end

  def create(conn, %{"organization" => organization_params}) do
    changeset = Organization.changeset(%Organization{}, organization_params)

    case Repo.insert(changeset) do
      {:ok, organization} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", organization_path(conn, :show, organization))
        |> render("show.json", organization: organization)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, _params) do
    id = _params["id"]

    organization = Repo.get!(Organization, id)

    render(conn, "show.json", organization: organization)
  end

  def update(conn, %{"id" => id, "organization" => organization_params}) do
    organization = Repo.get!(Organization, id)
    if organization_params["data"] do
      new_data = Map.merge(organization.data , organization_params["data"])
      organization_params = %{organization_params | "data" => new_data}
    end
    changeset = Organization.changeset(organization, organization_params)

    case Repo.update(changeset) do
      {:ok, organization} ->
        render(conn, "show.json", organization: organization)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    organization = Repo.get!(Organization, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(organization)

    send_resp(conn, :no_content, "")
  end

  def import_organization(conn, %{"mapping" => mapping, "file_name" => file_name, "company_id" => company_id }) do
   
    organization_params = %{"company_id" => company_id}
    table = File.read!("tmp/#{file_name}.csv") |> ExCsv.parse! |> ExCsv.with_headings |> Enum.to_list
    File.rm!("tmp/#{file_name}.csv")

    total_rows = Enum.count(table)-1
    for i <- 0..total_rows do
      first_row = Enum.at(table, i)
      # find only mapped values from csv
      maps = for {db_col,csv_col} <- mapping do
        maps = %{db_col => first_row[csv_col]}
      end
      organization_params = Enum.reduce(maps, organization_params, fn (map, acc) -> Map.merge(acc, map) end) 
      changeset = Organization.changeset(%Organization{}, organization_params)   
      case Repo.insert(changeset) do
        {:ok, organization} ->
          conn
          |> render("show.json", organization: organization)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
      end
    end
     send_resp(conn, :no_content, "")
  end
end
