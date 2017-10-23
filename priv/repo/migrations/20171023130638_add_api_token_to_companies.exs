defmodule CercleApi.Repo.Migrations.AddApiTokenToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :api_token, :string
    end
  end
end
