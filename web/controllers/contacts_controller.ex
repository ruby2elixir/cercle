defmodule CercleApi.ContactsController do
  use CercleApi.Web, :controller

  plug CercleApi.Plugs.RequireAuth

  alias CercleApi.Contact
  alias CercleApi.Organization
  alias CercleApi.TimelineEvent
  alias CercleApi.Activity
	
  alias CercleApi.Company

	require Logger
	
  def index(conn, _params) do
    
    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    query = from p in Contact,
      where: p.company_id == ^company_id,
      order_by: [desc: p.updated_at]

		leads_pending = Repo.all(query)   |> Repo.preload([:organization,timeline_event: from(CercleApi.TimelineEvent, order_by: [desc: :inserted_at])])

		conn
		  |> put_layout("adminlte.html")
		  |> render("index.html", leads_pending: leads_pending , company: company)
  end



  def new(conn, _params) do
    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]

    conn
      |> put_layout("adminlte.html")
      |> render("new.html", company: company)
  end

  def edit(conn, %{"id" => id}) do
    company_id = conn.assigns[:current_user].company_id
    contact = Repo.get!(Contact, id) |> Repo.preload([:organization, :company])
    company = Repo.get!(CercleApi.Company, contact.company_id) |> Repo.preload([:users])

    query = from p in Organization,
      where: p.company_id == ^company_id,
      order_by: [desc: p.inserted_at]
    organizations = Repo.all(query)

    query = from event in CercleApi.TimelineEvent,
      where: event.contact_id == ^contact.id,
      order_by: [desc: event.inserted_at]
    events = Repo.all(query) |> Repo.preload [:user]

    query = from opportunity in CercleApi.Opportunity,
      where: opportunity.main_contact_id == ^contact.id,
      where: opportunity.status == 0,
      order_by: [desc: opportunity.inserted_at]
    opportunities = Repo.all(query)

    query = from activity in CercleApi.Activity,
      where: activity.contact_id == ^contact.id,
      where: activity.is_done == false,
      order_by: [desc: activity.inserted_at]
    activities = Repo.all(query) |> Repo.preload [:user]

    opportunity = List.first(opportunities)
    if opportunity do 
      contact_ids = opportunity.contact_ids
      query = from contact in CercleApi.Contact,
        where: contact.id in ^contact_ids
      opportunity_contacts = Repo.all(query)
    end

    

    changeset = Contact.changeset(contact)
		conn
		  |> put_layout("adminlte.html")
		  |> render("edit.html", activities: activities, opportunity: opportunity, contact: contact, changeset: changeset, company: company, events: events, organizations: organizations, opportunity_contacts: opportunity_contacts)
  end



  def update(conn, %{"id" => id, "reward" => reward_params, "comment" => comment}) do
  end

  
  def statistics(conn, _params) do
    company_id = conn.assigns[:current_user].company_id
    company = Repo.get!(CercleApi.Company, company_id) |> Repo.preload [:users]
    users = company.users
    map = Enum.reduce users, %{}, fn x, acc ->
      user_id =  x.id
      query = from p in TimelineEvent,
        where: p.user_id == ^user_id,
        where: p.inserted_at > datetime_add(^Ecto.DateTime.utc, -1, "week"),
        where: p.action_type == "meeting",
        order_by: [desc: p.updated_at]
      nb_meetings = length(Repo.all(query))
      

      query = from p in TimelineEvent,
        where: p.user_id == ^user_id,
        where: p.inserted_at > datetime_add(^Ecto.DateTime.utc, -1, "week"),
        where: p.action_type == "call",
        order_by: [desc: p.updated_at]
      nb_calls = length(Repo.all(query))
      

      query = from p in TimelineEvent,
        where: p.user_id == ^user_id,
        where: p.inserted_at > datetime_add(^Ecto.DateTime.utc, -1, "week"),
        where: p.action_type == "email",
        order_by: [desc: p.updated_at]
      nb_emails = length(Repo.all(query))
      Map.put(acc, x.id, [nb_meetings, nb_calls, nb_emails])
    end
    conn
      |> put_layout("adminlte.html")
      |> render("statistics.html", company: company, stat: map)
  end

end
