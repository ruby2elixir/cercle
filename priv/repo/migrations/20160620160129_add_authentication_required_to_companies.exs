defmodule CercleApi.Repo.Migrations.AddAuthenticationRequiredToCompanies do
  use Ecto.Migration

  def change do
    alter table(:companies) do
      add :authentication_required, :boolean, default: false
    end
  end
end
