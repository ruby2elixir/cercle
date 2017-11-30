defmodule CercleApi.SettingsController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company, Tag, UserCompany}

  def team_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = Repo.preload(current_company(conn), [:users])

    conn
    |> put_layout("adminlte.html")
    |> render "team_edit.html", company: company
  end

  def remove_team_member(conn, %{"user_id" => user_id}) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)

    if user.id != String.to_integer(user_id) do
      team_member = UserCompany
      |> Repo.get_by(user_id: user_id, company_id: company.id)

      case Repo.delete(team_member) do
        {:ok, _} ->
          conn
          |> put_flash(:success, "Team member removed successfully")
          |> redirect(to: front_settings_path(conn, :team_edit, company))
        {:error, _} ->
          conn
          |> put_flash(:error, "Unable to remove team member")
          |> redirect(to: front_settings_path(conn, :team_edit, company))
      end
    end
  end

  def fields_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
    changeset = Company.changeset(company)

    conn
    |> put_layout("adminlte.html")
    |> render "fields_edit.html", company: company, changeset: changeset, settings: true
  end

  def tags_edit(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
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
    company = current_company(conn)
    email_api_token = Company.set_email_api_token(company)
    conn
    |> put_layout("adminlte.html")
    |> render "api_key.html", company: company, email_api_token: email_api_token
  end

  def team_invitation(conn, %{"user" => %{"email" => ""}}) do
    company = current_company(conn)
    conn
    |> put_flash(:error, "Unable to send invitation link due to some error!")
    |> redirect(to: front_settings_path(conn, :team_edit, company))
  end

  def team_invitation(conn, %{"user" => %{"email" => receiver_email}}) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
    values = %{"company_id": "#{company.id}", "email": "#{receiver_email}"}
    encoded_values = URI.encode(Cipher.cipher(values))

    try do
      user
      |> invitation_email(receiver_email, company, encoded_values)
      |> CercleApi.Mailer.deliver
      conn
      |> put_flash(:success, "Invitation link sent successfully!")
      |> redirect(to: front_settings_path(conn, :team_edit, company))
    rescue RuntimeError ->
      conn
      |> put_flash(:error, "Unable to send invitation link due to some error!")
      |> redirect(to: front_settings_path(conn, :team_edit, company))
    end
  end

  defp invitation_email(sender, receiver_email, company, encoded_values) do
    %Mailman.Email{
      subject: sender.full_name <> " invited to join " <> company.title,
      from: "referral@cercle.co",
      to: [receiver_email],
      html: Phoenix.View.render_to_string(
        CercleApi.EmailView,
        "team_invitation.html",
        sender: sender, receiver_email: receiver_email,
        company_name: company.title, encoded_values: encoded_values)
      }
  end

  def webhooks(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)

    conn
    |> put_layout("adminlte.html")
    |> render("webhooks.html", company: company, user: user)
  end
end
