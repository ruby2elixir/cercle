defmodule CercleApi.Repo.Migrations.AddPrivilegeCodeToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :previlege_code, :string, limit: 50
    end
  end
end
