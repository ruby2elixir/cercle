defmodule CercleApi.Repo.Migrations.AddDefaultLanguageToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :default_language, :string, limit: 10, default: "en"
    end
  end
end
