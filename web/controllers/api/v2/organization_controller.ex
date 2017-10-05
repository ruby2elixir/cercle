defmodule CercleApi.APIV2.OrganizationController do
  use CercleApi.Web, :controller
  alias CercleApi.{Organization, Contact, Company, User}

  plug CercleApi.Plug.EnsureAuthenticated
  plug CercleApi.Plug.CurrentUser

  plug :scrub_params, "organization" when action in [:create, :update]

  plug :authorize_resource, model: Organization, only: [:update, :delete, :show],
  unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
  not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  def index(conn, %{"user_id" => user_id}) do
    user = Repo.get(User, user_id)
    company = current_company(conn)

    organizations = Organization
    |> Organization.by_company(company.id)
    |> Organization.order_by_date
    |> Repo.all

    render(conn, "index.json", organizations: organizations)
  end

  def index(conn, _params) do
    organizations = Repo.all(Organization)
    render(conn, "index.json", organizations: organizations)
  end

  def search(conn, _params) do
    company = current_company(conn)
    q = _params["q"]

    if q do
      query = from o in Organization,
        where: o.company_id == ^company.id,
        where: ilike(o.name, ^"#{q}%"),
        order_by: o.name
      organizations = Repo.all(query)
    else
      organizations = []
    end

    render(conn, "index.json", organizations: organizations)
  end

  def create(conn, %{"organization" => organization_params}) do
    user = CercleApi.Plug.current_user(conn)
    company = current_company(conn)

    changeset = company
      |> Ecto.build_assoc(:organizations)
      |> Organization.changeset(organization_params)

    case Repo.insert(changeset) do
      {:ok, organization} ->
        conn
        |> put_status(:created)
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

  def update(conn, %{"id" => id, "organization" => organization_params} = params) do
    organization = Repo.get!(Organization, id)
    contact_id = params |> Dict.get("contact_id")

    if organization_params["data"] do
      new_data = Map.merge(organization.data , organization_params["data"])
      organization_params = %{organization_params | "data" => new_data}
    end
    changeset = Organization.changeset(organization, organization_params)
    case Repo.update(changeset) do
      {:ok, organization} ->
        if contact_id do
          contact = Contact
          |> Contact.preload_data
          |> Repo.get(contact_id)
          channel = "contacts:"  <> to_string(contact.id)
          CercleApi.Endpoint.broadcast!(channel, "update", %{
                contact: contact,
                organization: contact.organization
                                        })
        end
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
    # send_resp(conn, :no_content, "")
    json conn, %{status: 200}
  end
end
