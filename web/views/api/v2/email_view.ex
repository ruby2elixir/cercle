defmodule CercleApi.APIV2.EmailView do
  use CercleApi.Web, :view

  def render("index.json", %{emails: emails}) do
    %{data: render_many(emails, CercleApi.APIV2.EmailView, "email.json")}
  end

  def render("email.json", %{email: email}) do
    email_json(email)
  end

  def email_json(email) do
    %{
      id: email.id,
      uid: email.uid,
      subject: email.subject,
      date: email.date,
      company_id: email.company_id,
      from_email: email.from_email,
      to_email: email.to_email,
      body: email.body
    }
  end
end
