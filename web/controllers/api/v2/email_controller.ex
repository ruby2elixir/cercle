defmodule CercleApi.APIV2.EmailController do
  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{Email, Repo}

  #plug CercleApi.Plug.EnsureAuthenticated when not action in [:webhook]

  def webhook(conn, _params) do
    date = _params["Date"]
    |> Timex.parse!("%a, %d %b %Y %T %z", :strftime)
    |> Ecto.DateTime.cast!

    email_params = %{"uid" => _params["MessageID"], "from_email" => _params["From"], "to_email" => _params["To"], "subject" => _params["Subject"], "body" => _params["HtmlBody"], "date" => date, "company_id" => _params["company_id"]}

    email = Repo.get_by(Email, uid: email_params["uid"])

    if email do
      changeset = Email.changeset(email, email_params)
      Repo.update(changeset)

      text conn, "OK"
    else
      changeset = Email.changeset(%Email{}, email_params)
      case Repo.insert(changeset) do
        {:ok, email} ->
          text conn, "OK"
        {:error, changeset} ->
          raise "Error: #{inspect(changeset)}"
      end
    end
  end

  def index(conn, %{"from_email" => from_email}) do
    company = current_company(conn)
    query = from p in Email,
      where: p.company_id == ^company.id,
      where: ilike(p.from_email, ^from_email),
      order_by: [desc: p.inserted_at]

    emails = query
    |> Repo.all
    render(conn, "index.json", emails: emails)
  end

  def index(conn, %{}) do
    company = current_company(conn)
    query = from p in Email,
      where: p.company_id == ^company.id,
      order_by: [desc: p.inserted_at]

    emails = query
    |> Repo.all
    render(conn, "index.json", emails: emails)
  end
end
