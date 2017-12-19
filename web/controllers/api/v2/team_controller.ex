defmodule CercleApi.APIV2.TeamController do
  use CercleApi.Web, :controller

  alias CercleApi.{User, Company, UserCompany}

  plug CercleApi.Plug.EnsureAuthenticated

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
    team_query = from uc in UserCompany,
      where: uc.user_id == ^id and uc.user_id != ^user.id,
      where: uc.company_id == ^company.id
    team_member = Repo.one(team_query)

    case Repo.delete(team_member) do
      {:ok, _} ->
        json conn, %{status: 200}
      {:error, _} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{reason: "Unable to remove team member"})
    end

  end

  def invitation(conn, %{"user" => %{"email" => ""}}) do
    company = current_company(conn)
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{reason: "Unable to send invitation link due to some error!"})
  end

  def invitation(conn, %{"user" => %{"email" => receiver_email}}) do
    user = Guardian.Plug.current_resource(conn)
    company = current_company(conn)
    values = %{"company_id": "#{company.id}", "email": "#{receiver_email}"}
    encoded_values = URI.encode(Cipher.cipher(values))

    try do
      user
      |> invitation_email(receiver_email, company, encoded_values)
      |> CercleApi.Mailer.deliver

      json conn, %{status: 200}
    rescue RuntimeError ->
      conn
      |> put_status(:unprocessable_entity)
      |> json(%{reason: "Unable to send invitation link due to some error!"})
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
end
