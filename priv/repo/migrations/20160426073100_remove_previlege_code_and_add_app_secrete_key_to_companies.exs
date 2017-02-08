defmodule CercleApi.Repo.Migrations.RemovePrevilegeCodeAndAddAppSecreteKeyToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      remove :previlege_code
      add :app_secret_key, :string, limit: 20
    end
  end
end
