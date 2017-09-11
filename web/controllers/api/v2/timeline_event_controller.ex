defmodule CercleApi.APIV2.TimelineEventController do
  use CercleApi.Web, :controller
  alias CercleApi.{TimelineEvent, User, Contact, Board, Repo}

  plug CercleApi.Plug.EnsureAuthenticated
  plug CercleApi.Plug.CurrentUser
  plug :authorize_resource, model: TimelineEvent, only: [:delete, :update],
    unauthorized_handler: {CercleApi.Helpers, :handle_json_unauthorized},
    not_found_handler: {CercleApi.Helpers, :handle_json_not_found}

  plug :scrub_params, "timeline_event" when action in [:create, :update]

  def index(conn, params) do
    current_user = CercleApi.Plug.current_user(conn)
    te = Repo.preload(Repo.all(TimelineEvent), [:user])

    render(conn, "index.json", timeline_events: te)
  end

  def create(conn, %{"timeline_event" => timeline_event_params}) do
    current_user = CercleApi.Plug.current_user(conn)

    changeset = current_user
    |> build_assoc(:timeline_event)
    |> TimelineEvent.changeset(timeline_event_params)

    case Repo.insert(changeset) do
      {:ok, timeline_event} ->
        timeline_event_reload = timeline_event
        |> Repo.preload([:user, card: [:board]])
        CercleApi.TimelineEventService.create(timeline_event_reload)

        ### THE CODE BELOW IS USELESS, WE NEED TO GET THE IDs OF THE USER WILL NOTIFIY INSTEAD OF PARSING THE CONTENT OF THE TEXTAREA
        company = conn
        |> current_company
        |> Repo.preload [:users]
        users = company.users

        comment = timeline_event_params["content"]
        parts = String.split(comment, " ")

        Enum.each parts, fn x ->
          Enum.each users, fn u ->
            if x == ("@" <> to_string(u.name)) do
              CercleApi.Mailer.deliver(
                notification_email(u.login, timeline_event_reload.card, true, comment, company, current_user , u)
              )
            end
          end
        end

        conn
        |> put_status(:created)
        |> render("show.json", timeline_event: timeline_event_reload)

      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def notification_email(emailTo, card, status, comment, company, user, user2) do
      %Mailman.Email{
        subject: user.user_name <> " commented on " <> card.name,
        from: "referral@cercle.co",
        to: [emailTo],
        html: Phoenix.View.render_to_string(CercleApi.EmailView,
          "event_notification.html", card: card, status: status,
          comment: comment, company: company, user: user, user2: user2)
        }
  end

  def update(conn, %{"id" => id, "timeline_event" => timeline_event_params}) do
    timeline_event = Repo.get!(TimelineEvent, id)
    changeset = TimelineEvent.changeset(timeline_event, timeline_event_params)

    case Repo.update(changeset) do
      {:ok, timeline_event} ->
        timeline_event = timeline_event
        |> Repo.preload([:user, :card])
        CercleApi.TimelineEventService.update(timeline_event)

        render(conn, "show.json", timeline_event: timeline_event)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CercleApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    timeline_event = TimelineEvent
    |> Repo.get!(id)
    |> Repo.preload([:card])
    CercleApi.TimelineEventService.delete(timeline_event)
    Repo.delete!(timeline_event)
    json conn, %{status: 200}
  end
end
