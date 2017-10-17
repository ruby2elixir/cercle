defmodule CercleApi.Factory do
  use ExMachina.Ecto, repo: CercleApi.Repo

  alias CercleApi.{
    User, Company, Activity, Organization, Contact,
    Board, BoardColumn, Card, CardAttachment,
    TimelineEvent, UserCompany, Notification
  }
  alias ExOauth2Provider.OauthApplications.OauthApplication
  alias ExOauth2Provider.OauthAccessTokens.OauthAccessToken

  def user_company_factory do
    %UserCompany{user_id: "", company_id: "" }
  end


  def company_factory do
    %Company{ title: "Coca-Cola Inc." }
  end

  def user_factory do
    %User{
      login: sequence(:login, &"email-#{&1}@foo.com"),
      name: "name",
      password: "supersecret",
      user_name: "test"
    }
  end

  def organization_factory do
    %Organization{
      name: "Org1",
      company: build(:company),
      user: build(:user)
    }
  end

  def contact_factory do
    %Contact{
      first_name: "TestContact",
      last_name: "1",
      company: build(:company),
      user: build(:user),
      organization: build(:organization)
    }
  end

  def board_factory do
    %Board{
      name: "TestBoard1",
      type_of_card: 0,
      company: build(:company)
    }
  end

  def board_column_factory do
    %BoardColumn{
      name: "Step1",
      order: "1",
      board: build(:board)
    }
  end

  def activity_factory do
    %Activity{
      #due_date, Ecto.DateTime
      is_done: false,
      title: "Test Activity",
      user: build(:user),
      company: build(:company),
      card: build(:card)
    }
  end

  def card_factory do
    %Card{
      name: "Test",
      description: "Test Desc",
      status: 0,
      user: build(:user),
      company: build(:company),
      board: build(:board),
      board_column: build(:board_column)
    }
  end

  def card_attachment_factory do
    %CardAttachment{
      card: build(:card)
    }
  end

  def timeline_event_factory do
    %TimelineEvent{
      event_name: "Test Event",
      content: "Test Content",
      user: build(:user),
      company: build(:company),
      card: build(:card),
      contact: build(:contact),
      metadata: %{}
    }
  end

  def oauth_application_factory do
    %OauthApplication{
      secret: "4e3e0cd73b435260881b3004346bc2b4",
      uid: "a63311608bba2a432438edf435351bc6",
      redirect_uri: "https://zapier.com/dashboard/auth/oauth/return/App66908API/",
      scopes: "read",
      owner_id: 1,
      name: "Test App"
    }
  end

  def oauth_access_token_factory do
    %OauthAccessToken{
      application: build(:oauth_application),
      token: "77345dc3a5a0e7bb9409b3e7c811c2464dc2107126353360f851924f072b3512",
      expires_in: 7200
    }
  end

  def notification_factory do
    %Notification{
      sent: false,
      notification_type: "start"
    }
  end
end
