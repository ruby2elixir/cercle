defmodule CercleApi.Repo.Migrations.AddPasswordHashToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :password_hash, :string
    end

    create unique_index(:companies, [:admin_email])
  end
end
