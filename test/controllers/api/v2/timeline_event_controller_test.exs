defmodule CercleApi.APIV2.TimelineEventTest do
  use CercleApi.ConnCase
  @valid_attrs %{name: "Board1"}
  @invalid_attrs %{}
  alias CercleApi.{Contact,TimelineEvent,Opportunity}

  setup %{conn: conn} do
    company = insert_company()
    user = insert_user(username: "test", company_id: company.id)
    {:ok, jwt, _full_claims} = Guardian.encode_and_sign(user)
    conn = put_req_header(conn, "authorization", "Bearer #{jwt}")
    {:ok, conn: conn, user: user, company: company}
  end

  test "timeline_event index with valid params", state do


    changeset = Contact.changeset(%Contact{}, %{
          name: "Contact1", company_id: state[:company].id})
    contact = Repo.insert!(changeset)

    changeset = Opportunity.changeset(%Opportunity{}, %{
          name: "Project #1", main_contact_id: contact.id,
          company_id: state[:company].id, user_id: state[:user].id})
    opportunity = Repo.insert!(changeset)

    changeset = TimelineEvent.changeset(%TimelineEvent{}, %{
          event_name: "Comment", content: "Good", contact_id: contact.id,
          opportunity_id: opportunity.id , company_id: state[:company].id,
          user_id: state[:user].id})
    te = Repo.insert!(changeset)
    conn = get state[:conn], "/api/v2/timeline_events"

    assert json_response(conn, 200) == render_json(
      CercleApi.APIV2.TimelineEventView, "index.json", timeline_events: [te]
    )
  end
end
