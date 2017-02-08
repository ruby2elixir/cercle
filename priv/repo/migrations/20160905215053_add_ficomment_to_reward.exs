defmodule CercleApi.Repo.Migrations.AddFicommentToReward do
  use Ecto.Migration

  def change do
  	alter table(:rewards) do
     	add :referral_comment, :text
    end
  end
end
