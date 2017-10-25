defmodule CercleApi.Repo.Migrations.AddEmailApiTokenToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :email_api_token, :string
    end
  end
end
