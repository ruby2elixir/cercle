defmodule CercleApi.APIV2.ContactExportController do
  require Logger
  use CercleApi.Web, :controller
  use Timex

  alias CercleApi.{Repo, Contact}

  plug CercleApi.Plug.EnsureAuthenticated
  plug CercleApi.Plug.CurrentUser

  def export(conn, %{"contact_ids" => contact_ids}) do
    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"contact.csv\"")
    |> send_resp(200, csv_content(contact_ids))
  end

  def csv_content(contact_ids) do
    query = from(c in Contact, where: c.id in ^contact_ids)
    contacts = query
    |> Repo.all
    |> Enum.map(fn(m) -> [m] end)

    header = [
      ["first_name", "last_name", "email", "phone", "job_title", "description"]
    ]
    |> CSV.encode
    |> Enum.to_list

    content = contacts
    |> CSV.encode
    |> Enum.to_list
    |> to_string

    header ++ content |> to_string
  end
end
