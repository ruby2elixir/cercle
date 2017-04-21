defmodule CercleApi.SettingsController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company, Tag}

  def profile_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    changeset = User.changeset(user)
    if user.company_id do
      company = Repo.get(Company, user.company_id)
    end

    conn
    |> put_layout("adminlte.html")
    |> render("profile_edit.html", changeset: changeset, company: company, user: user)
  end

  def profile_update(conn, %{"user" => user_params}) do
    user = Guardian.Plug.current_resource(conn)
    changeset = User.update_changeset(user, user_params)
    if user.company_id do
      company = Repo.get(Company, user.company_id)
    end

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: "/settings/profile_edit")
      {:error, changeset} ->
        conn
        |> put_layout("adminlte.html")
        |> render("profile_edit.html", changeset: changeset, company: company, user: user)
    end
  end

  def team_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    company = Repo.get!(Company, company_id) |> Repo.preload [:users]

    conn
    |> put_layout("adminlte.html")
    |> render "team_edit.html", company: company
  end

  def fields_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    company = Repo.get!(Company, company_id)
    changeset = Company.changeset(company)

    conn
    |> put_layout("adminlte.html")
    |> render "fields_edit.html", company: company, changeset: changeset, settings: true
  end

  def company_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    company = Repo.get!(Company, company_id)
    changeset = Company.changeset(company)

    conn
    |> put_layout("adminlte.html")
    |> render "company_edit.html", company: company, changeset: changeset, settings: true
  end

  def company_update(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id
    company_params = _params["company"]

    company = Repo.get!(Company, company_id)
    changeset = Company.changeset(company, company_params)

    case Repo.update(changeset) do
      {:ok, company} ->
        conn
        |> put_flash(:success, "Company updated successfully.")
        |> redirect(to: "/settings/company_edit")
      {:error, changeset} ->
        render(conn, "company_edit.html", company: company, changeset: changeset, settings: true)
    end
  end

  def tags_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get(Company, user.company_id)
    query = from t in Tag,
      where: t.company_id == ^company.id,
      order_by: [desc: t.inserted_at]
    tags = Repo.all(query)
    conn
    |> put_layout("adminlte.html")
    |> render "tags_edit.html", tags: tags
  end

  def api_key(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get(Company, user.company_id)
    conn
    |> put_layout("adminlte.html")
    |> render "api_key.html", company: company
  end

  def team_invitation(conn, %{"user" => user_params}) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.get!(Company, user.company_id)
    receiver_email = user_params["email"]
    values = %{"company_id": "#{company.id}", "email": "#{receiver_email}"}
    encoded_values = URI.encode encoded_values(Cipher.cipher(values))
    try do
      CercleApi.Mailer.deliver invitation_email(user, receiver_email, company.title, encoded_values)
      conn
      |> put_flash(:success, "Invitation link sent successfully!")
      |> redirect(to: "/settings/team_edit")
    rescue RuntimeError ->
      conn
      |> put_flash(:error, "Unable to send invitation link due to some error!")
      |> redirect(to: "/settings/team_edit")
    end
  end

  def invitation_email(sender, receiver_email, company_name, encoded_values) do
    %Mailman.Email{
      subject: sender.user_name <> " invited to join " <> company_name,
      from: "referral@cercle.co",
      to: [receiver_email],
      html: Phoenix.View.render_to_string(CercleApi.EmailView, "team_invitation.html", sender: sender, receiver_email: receiver_email, company_name: company_name, encoded_values: encoded_values)
      }
  end
end
