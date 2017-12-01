defmodule CercleApi.APIV2.EmailController do
  require Logger
  use CercleApi.Web, :controller
  use Timex
  alias CercleApi.{Email, Repo, Company}

  plug CercleApi.Plug.EnsureAuthenticated when not action in [:create]
  plug :token_authenticate when action in [:create]

  defp token_authenticate(conn, _params) do
    case conn.params["source"] do
    "postmark" ->
      company = Repo.get(Company, conn.params["company_id"])
      email_api_token = Company.set_email_api_token(company)

      if conn.params["token"] == email_api_token do
        conn
      else
        conn
        |> send_resp(401, "Unauthenticated")
        |> halt()
      end
    _ ->
      CercleApi.Plug.EnsureAuthenticated.call(conn, conn.params)
    end
  end

  def extract_emails(emails) when is_nil(emails) when emails == [], do: []
  def extract_emails([t]), do: [t["Email"]]
  def extract_emails([h | t]), do: [h["Email"] | extract_emails(t)]

  defp parse_date(date) do
    date
    |> String.replace(~r/\(\w+\)/, "")
    |> String.trim
    |> Timex.parse!("%a, %d %b %Y %T %z", :strftime)
    |> Ecto.DateTime.cast!
  rescue
    _ -> Ecto.DateTime.cast!(Timex.now)
  end

  def create(conn, %{"source" => "postmark"}) do
    raw_params = conn.params
    date = parse_date(raw_params["Date"])

    to_emails = extract_emails(raw_params["ToFull"])
    cc_emails = extract_emails(raw_params["CcFull"])
    bcc_emails = extract_emails(raw_params["BccFull"])
    meta = %{
      "FromFull" => raw_params["FromFull"],
      "ToFull" => raw_params["ToFull"],
      "CcFull" => raw_params["CcFull"],
      "BccFull" => raw_params["BccFull"]
    }

    email_params = %{
      "uid" => raw_params["MessageID"], "from_email" => raw_params["From"],
      "to" => to_emails, "cc" => cc_emails, "bcc" => bcc_emails,
      "subject" => raw_params["Subject"], "body" => raw_params["HtmlBody"],
      "body_text" => raw_params["TextBody"], "date" => date,
      "company_id" => raw_params["company_id"], "meta" => meta
    }

    email = Repo.get_by(Email, uid: email_params["uid"])

    if email do
      changeset = Email.changeset(email, email_params)
      Repo.update(changeset)

      text conn, "OK"
    else
      changeset = Email.changeset(%Email{}, email_params)
      case Repo.insert(changeset) do
        {:ok, _email} -> text conn, "OK"
        {:error, changeset} -> raise "Error: #{inspect(changeset)}"
      end
    end
  end

  def index(conn, %{"email" => email}) do
    company = current_company(conn)
    query = from p in Email,
      where: p.company_id == ^company.id,
      where: ilike(p.from_email, ^email) or fragment("? = ANY (?)", ^email, p.to),
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
