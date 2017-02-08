defmodule CercleApi.APIV2.ContactController do
  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.Contact
  alias CercleApi.Company
  alias CercleApi.Organization
  alias CercleApi.Opportunity
  alias CercleApi.User
  alias CercleApi.Activity

  plug :scrub_params, "contact" when action in [:create, :update]


  def testing_email(company, contact) do
      %Mailman.Email{
        subject: "You received a new referral",
        from: "referral@cercle.co",
        to: [company.admin_email],
				html: Phoenix.View.render_to_string(CercleApi.EmailView, "new_referral.html", contact: contact, company: company)
        }
  end


  def index(conn, _params) do
    contacts = Repo.all(Contact)
    render(conn, "index.json", contacts: contacts)
  end

  def create(conn, %{"contact" => contact_params}) do
    ### CHECK IF COMPANY
    company_id = contact_params["company_id"]
    opportunity_name = contact_params["name"] <> " deal"
    if contact_params["email"] do 
      domain_email = List.first(Enum.take(String.split(contact_params["email"], "@"), -1))
      opportunity_name = domain_email <> " deal"
      Logger.info  "==> Logging this text!"
      Logger.info domain_email
  
      query = from organization in Organization,
        where: organization.website == ^domain_email,
        where: organization.company_id == ^company_id
  
      organizations = Repo.all(query)
  
      if Enum.count(organizations) == 0 do
        organization_params = %{"name" => domain_email, "website" => domain_email, "company_id" => company_id}
        changeset = Organization.changeset(%Organization{}, organization_params)
        case Repo.insert(changeset) do
          {:ok, org} ->
            organization_id = org.id
        end
      end
  
      organizations = Repo.all(query)
  
      organization = Enum.at(organizations, 0)
      organization_id = organization.id

      

  
      contact_params = %{contact_params | "organization_id" => organization_id}
    end

    ## AND ADD COMPANY PARAMETER INTO CONTACTS
    #contact_params = %{ contact_params | "organization_id" => organization_id }
    changeset = Contact.changeset(%Contact{}, contact_params)
    case Repo.insert(changeset) do
      {:ok, contact} ->
        
        changeset = Opportunity.changeset(%Opportunity{}, %{"name" => opportunity_name, "company_id" => contact.company_id , "main_contact_id" => contact.id, "user_id" => contact.user_id  })
        Repo.insert(changeset)

        conn
        |> put_status(:created)
        |> render("show.json", contact: contact)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"user_id" => user_id, "company_id" => company_id}) do
    
    query = from contact in Contact,
      where: contact.user_id == ^user_id and contact.company_id == ^company_id,
      order_by: [desc: contact.id]

    contacts = Repo.all(query)
    render(conn, "index.json", contacts: contacts)
  end

  def update(conn, %{"id" => id, "contact" => contact_params}) do
    contact = Repo.get!(Contact, id)
    if contact_params["data"] do
      new_data = Map.merge(contact.data , contact_params["data"])
      contact_params = %{contact_params | "data" => new_data}
    end
    changeset = Contact.changeset(contact, contact_params)

    case Repo.update(changeset) do
      {:ok, contact} ->
        render(conn, "show.json", contact: contact)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    contact = Repo.get!(Contact, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(contact)

    send_resp(conn, :no_content, "")
  end
end
