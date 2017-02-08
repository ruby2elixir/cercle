defmodule CercleApi.API.CompanyControllerTest do
  use CercleApi.ConnCase

  alias CercleApi.API.Company
  @valid_attrs %{admin_email: "some content", description1: "some content", description2: "some content", image_url: "some content", individual: true, reward: "some content", subtitle1: "some content", subtitle2: "some content", title: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, company_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    company = Repo.insert! %Company{}
    conn = get conn, company_path(conn, :show, company)
    assert json_response(conn, 200)["data"] == %{"id" => company.id,
      "title" => company.title,
      "admin_email" => company.admin_email,
      "image_url" => company.image_url,
      "subtitle1" => company.subtitle1,
      "description1" => company.description1,
      "subtitle2" => company.subtitle2,
      "description2" => company.description2,
      "reward" => company.reward,
      "individual" => company.individual}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, company_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, company_path(conn, :create), company: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Company, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, company_path(conn, :create), company: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    company = Repo.insert! %Company{}
    conn = put conn, company_path(conn, :update, company), company: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Company, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    company = Repo.insert! %Company{}
    conn = put conn, company_path(conn, :update, company), company: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    company = Repo.insert! %Company{}
    conn = delete conn, company_path(conn, :delete, company)
    assert response(conn, 204)
    refute Repo.get(Company, company.id)
  end
end
