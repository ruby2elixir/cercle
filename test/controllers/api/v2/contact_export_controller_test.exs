defmodule CercleApi.APIV2.ContactExportControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory

  alias CercleApi.{Contact}

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: company}
  end

  test "export conact to csv", state do
    contact = insert(:contact)
    csv = CercleApi.APIV2.ContactExportController.csv_content([contact.id])
    conn = post state[:conn], "/api/v2/company/#{state[:company].id}/contact/export", contact_ids: [contact.id]

    assert response_content_type(conn, :csv) =~ "charset=utf-8"
    assert conn.resp_body == csv
    assert conn.status == 200
  end
end
