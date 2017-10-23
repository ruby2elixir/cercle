defmodule CercleApi.APIV2.EmailControllerTest do
  use CercleApi.ConnCase
  use Timex
  import CercleApi.Factory

  alias CercleApi.{Company}

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: company}
  end

  test "create/2 create email with valid inbound data", state do
    conn = post state[:conn], "/api/v2/company/#{state[:company].id}/email?token=#{Company.get_or_set_email_api_token(state[:company])}&source=postmark", %{"MessageID" => "123",
      "From" => "abc@xyz.com",
      "To" => "xyz@abc.com",
      "Subject" => "Test subject",
      "HtmlBody" => "Test body",
      "Date" => "Sun, 22 Oct 2017 00:12:41 -0400" }

    assert text_response(conn, 200) == "OK"
  end

  test "create/2 create email without token should return unauthenticated response", state do
    conn = post state[:conn], "/api/v2/company/#{state[:company].id}/email", %{"MessageID" => "123",
      "From" => "abc@xyz.com",
      "To" => "xyz@abc.com",
      "Subject" => "Test subject",
      "HtmlBody" => "Test body",
      "Date" => "Sun, 22 Oct 2017 00:12:41 -0400" }

    assert text_response(conn, 401) == "Unauthenticated"
  end
end
