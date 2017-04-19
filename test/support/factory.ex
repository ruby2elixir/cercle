defmodule CercleApi.Factory do
  use ExMachina.Ecto, repo: CercleApi.Repo

  alias CercleApi.{User, Company, Activity, Organization, Contact}
  alias CercleApi.{Board, BoardColumn}

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
end
