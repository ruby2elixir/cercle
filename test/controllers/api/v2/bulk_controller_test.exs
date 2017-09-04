defmodule CercleApi.APIV2.BulkControllerTest do
  use CercleApi.ConnCase
  import CercleApi.Factory
  alias CercleApi.{Company,Contact,Tag}

  setup %{conn: conn} do
    user = insert(:user)
    company = insert(:company)
    add_company_to_user(user, company)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: company}
  end

  test "create bulk contact with contacts more than 100 records", %{conn: conn} do
    items = for i <- 0..150 do
      %{"contact" => %{"name" => "C#{i}", "email" => "c#{i}@test#{i}.com", "phone" => "00#{i}", "description" => "", "job_title" => ""}, "organization" => %{"name" => "org#{i}", "website" => "test#{i}.com", "description" => ""}}
    end
    conn = post conn, "/api/v2/bulk_contact_create", items: items, return: false
    assert json_response(conn, 200)["error_message"] == "Maximum 100 records are permitted per call"
  end

  test "create bulk contact with contacts less than 100", %{conn: conn} do
    items = [%{"contact" => %{"first_name" => "C", "last_name" => "1", "email" => "c1@test.com", "phone" => "123", "description" => "", "job_title" => ""}, "organization" => %{"name" => "org1", "website" => "test.com","description" => ""}}]
    conn = post conn, "/api/v2/bulk_contact_create", items: items, return: false
    assert json_response(conn, 200)["contacts"]
  end

  test "create bulk_tag_or_untag_contacts with more than 100 records", %{conn: conn} do
    tag_id = "1"
    untag = false
    contacts = for i <- 0..150 do
      Integer.to_string i
    end
    conn = post conn, "/api/v2/bulk_tag_or_untag_contacts", contacts: contacts, tag_id: tag_id, untag: untag, return: false
    assert json_response(conn, 200)["error_message"] == "Maximum 100 records are permitted per call"
  end

  test "create bulk_tag_or_untag_contacts with less than 100 records but params missing", %{conn: conn} do
    contacts = ["1"]
    conn = post conn, "/api/v2/bulk_tag_or_untag_contacts", contacts: contacts, tag_id: nil , untag: nil, return: false
    assert json_response(conn, 200)["responses"]["errors"] == "Parameters missing"
  end

  test "create bulk_tag_or_untag_contacts with invalid tag_id", %{conn: conn}  do
    untag = false
    tag_id = "1"
    contacts = ["1"]
    conn = post conn, "/api/v2/bulk_tag_or_untag_contacts", contacts: contacts, tag_id: tag_id, untag: untag, return: false
    assert json_response(conn, 200)["responses"]["errors"] == "Tag id #{tag_id} not found"
  end

  test "create bulk_tag_or_untag_contacts with invalid contact_id", state  do
    company_id = state[:company].id
    tag_id = Repo.insert!(%Tag{name: "Test Tag", company_id: company_id}).id
    str_tag_id = Integer.to_string(tag_id)
    untag = false
    contacts = ["1111"]
    conn = post state[:conn], "/api/v2/bulk_tag_or_untag_contacts", contacts: contacts, tag_id: str_tag_id, untag: untag, return: false
    assert json_response(conn, 200)["responses"] == [%{"error" => "Contact id 1111 not found", "status" => 400}]
  end

  test "create bulk_tag_or_untag_contacts with valid contact_id and tag_id", state  do
    company = state[:company]
    changeset = company
      |> Ecto.build_assoc(:contacts)
      |> Contact.changeset(%{"first_name" => "Contact", "last_name" => "1"})
    contact_id = Repo.insert!(changeset).id
    contacts = [Integer.to_string(contact_id)]
    tag_id = Repo.insert!(%Tag{name: "Test Tag", company_id: company.id}).id
    str_tag_id = Integer.to_string(tag_id)
    untag = false
    conn = post state[:conn], "/api/v2/bulk_tag_or_untag_contacts", contacts: contacts, tag_id: str_tag_id, untag: untag, return: false
    assert json_response(conn, 200)["responses"] == [%{"status" => 200, "success" => "Contact id #{contact_id} tagged/untagged successfully"}]
  end

end
