defmodule CercleApi.Repo.Migrations.AddAdminPhoneAndAdminNameToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :admin_name, :string, limit: 50
      add :admin_phone, :string, limit: 20
    end
  end
end
