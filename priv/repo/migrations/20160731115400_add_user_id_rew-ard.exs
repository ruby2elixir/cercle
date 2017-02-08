defmodule :"Elixir.CercleApi.Repo.Migrations.AddUserIdRew-ard" do
  use Ecto.Migration

  def change do
  	alter table(:rewards) do
      add :referral_company, :string
    end
    alter table(:reward_status_history) do
      add :user_id, :integer
    end
  end
end
