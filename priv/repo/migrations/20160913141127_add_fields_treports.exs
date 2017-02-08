defmodule CercleApi.Repo.Migrations.AddFieldsTreports do
  use Ecto.Migration

  def change do
  	alter table(:reward_status_history) do
     	add :is_a_reporting, :boolean, default: false
    end
  end
end
