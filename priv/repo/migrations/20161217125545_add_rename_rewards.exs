defmodule CercleApi.Repo.Migrations.AddRenameRewards do
  use Ecto.Migration

  def change do
  	rename table(:rewards), to: table(:contacts)
  	rename table(:reward_status_history), to: table(:timeline_events)
  end
end
