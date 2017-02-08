defmodule CercleApi.Repo.Migrations.CreateReward do
  use Ecto.Migration

  def change do
    create table(:rewards) do
      add :user_id, :integer
      add :company_id, :integer
      add :reward_value, :string
      add :user_name, :string
      add :email, :string
      add :status, :string

      timestamps
    end

  end
end
