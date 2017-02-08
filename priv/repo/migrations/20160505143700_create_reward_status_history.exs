defmodule CercleApi.Repo.Migrations.CreateRewardStatusHistory do
  use Ecto.Migration

  def change do
    create table(:reward_status_history) do
      add :reward_id, :integer
      add :status, :string
      add :comment, :text

      timestamps
    end

  end
end
