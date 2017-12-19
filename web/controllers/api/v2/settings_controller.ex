defmodule CercleApi.APIV2.SettingsController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company}

  plug CercleApi.Plug.EnsureAuthenticated

  def api_keys(conn, _) do
    company = current_company(conn)
    json conn, %{
      status: 200,
      keys: %{
        token: Guardian.Plug.current_token(conn),
        postmark_token: Company.set_email_api_token(company)
      }
    }
  end
end
