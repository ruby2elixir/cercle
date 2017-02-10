defmodule CercleApi.APIV2.TimelineEventController do
  use CercleApi.Web, :controller

  alias CercleApi.TimelineEvent
  alias CercleApi.User
  alias CercleApi.Contact

  def index(conn, _params) do
    te = Repo.all(TimelineEvent)
    render(conn, "index.json", timeline_events: te)
  end

  def create(conn, %{"timeline_event" => timeline_event_params}) do
    changeset = TimelineEvent.changeset(%TimelineEvent{}, timeline_event_params)
    case Repo.insert(changeset) do
      {:ok, timeline_event} ->
        
        timeline_event_reload = Repo.get!(CercleApi.TimelineEvent, timeline_event.id) |> Repo.preload [:user]
        html = Phoenix.View.render_to_string(CercleApi.ContactsView, "_timeline_event.html", timeline_event: timeline_event_reload)
        channel = "contacts:"  <> to_string(timeline_event_reload.contact_id)
        CercleApi.Endpoint.broadcast!( channel, "new:timeline_event", %{"html" => html})

        
        ### THE CODE BELOW IS USELESS, WE NEED TO GET THE IDs OF THE USER WILL NOTIFIY INSTEAD OF PARSING THE CONTENT OF THE TEXTAREA
        user = Repo.get_by(User, id: timeline_event_params["user_id"])
        contact = Repo.get!(CercleApi.Contact, timeline_event_params["contact_id"]) |> Repo.preload [:company]
      	comment = timeline_event_params["content"]
      	company = contact.company
      	company_id = company.id
      	parts = String.split(comment, " ")
        
        
      	if timeline_event_params["action_type"] == "meeting" or timeline_event_params["action_type"] == "call" or timeline_event_params["action_type"] == "email"  do
      		changeset = CercleApi.Contact.changeset(contact, %{})
      		Repo.update!(changeset, force: true)
      	end
        
        query = from p in User,
          where: p.company_id == ^company_id
        users = Repo.all(query)
        
        Enum.each parts, fn x ->
          Enum.each users, fn u ->
            if x == ("@" <> u.name) do
              CercleApi.Mailer.deliver notification_email(u.login, contact, true, comment, company, user ,  u)
            end
          end
        end

        conn
        |> put_status(:created)
        |> render("show.json", timeline_event: timeline_event)
        
        
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def notification_email(emailTo, reward, status, comment, company, user, user2) do
      %Mailman.Email{
        subject: user.user_name <> " commented on "<> reward.name,
        from: "referral@cercle.co",
        to: [emailTo],
        html: Phoenix.View.render_to_string(CercleApi.EmailView, "lead_notification.html", reward: reward, status: status, comment: comment, company: company, user: user, user2: user2)
        }
  end

 end
