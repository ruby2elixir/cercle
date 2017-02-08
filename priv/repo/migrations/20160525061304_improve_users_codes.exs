defmodule CercleApi.Repo.Migrations.ImproveUsersCodes do
  use Ecto.Migration

  def change do
		drop table(:user_codes)
		create table(:user_connections) do
      add :user_id, :integer
			add :entity_id, :integer
			add :entity_type, :string
      timestamps
    end
		
  end
end
