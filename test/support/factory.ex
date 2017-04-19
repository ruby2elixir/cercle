defmodule CercleApi.Factory do
  use ExMachina.Ecto, repo: CercleApi.Repo

  alias CercleApi.{User, Company, Activity, Organization, Contact}
  alias CercleApi.{Board, BoardColumn, Opportunity, TimelineEvent}

  def company_factory do
    %Company{ title: "Coca-Cola Inc." }
  end

  def user_factory do
    %User{
      login: sequence(:login, &"email-#{&1}@foo.com"),
      name: "name",
      password: "supersecret",
      user_name: "test",
      company: build(:company)
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
      name: "TestContact1",
      company: build(:company),
      user: build(:user),
      organization: build(:organization)
    }
  end

  def board_factory do
    %Board{
      name: "TestBoard1",
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
      opportunity: build(:opportunity),
      contact: build(:contact)
    }
  end

  def opportunity_factory do
    %Opportunity{
      name: "Test",
      description: "Test Desc",
      status: 0
    }
  end

  def timeline_event_factory do
    %TimelineEvent{
      event_name: "Test Event",
      content: "Test Content",
      user: build(:user),
      company: build(:company),
      opportunity: build(:opportunity),
      contact: build(:contact)
    }
  end
end
