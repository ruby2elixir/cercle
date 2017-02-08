defmodule CercleApi.Repo.Migrations.AddPlanToCompanies do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
      add :plan_id, :string, limit: 20
    end
  end
end
