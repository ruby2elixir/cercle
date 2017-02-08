defmodule CercleApi.Repo.Migrations.AddFieldsToManagers do
  use Ecto.Migration

  def change do
  	alter table(:rewards) do
     	add :manager_id, :integer
     	add :rating, :integer
    end
  end
end
