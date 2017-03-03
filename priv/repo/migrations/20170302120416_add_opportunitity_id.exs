defmodule CercleApi.Repo.Migrations.AddOpportunitityId do
  use Ecto.Migration

  def change do
  	alter table(:opportunities) do
    	remove :stage
    end

  	alter table(:timeline_events) do
      add :opportunity_id, :integer
    end

    alter table(:activities) do
      add :opportunity_id, :integer
    end
  end
end
