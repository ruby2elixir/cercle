defmodule CercleApi.Repo.Migrations.AddRenameRewards2 do
  use Ecto.Migration

  def change do
  	rename table(:timeline_events), :reward_id, to: :contact_id
  end
end
