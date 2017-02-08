defmodule CercleApi.Repo.Migrations.AddFitableReferrals do
  use Ecto.Migration

  def change do
  	create table(:reward_participants) do
     	add :reward_id, :integer
		  add :user_id, :integer
     	timestamps
    end
    alter table(:rewards) do
      	add :send_reminder_at, :datetime
    end
  end
end
