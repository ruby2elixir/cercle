defmodule CercleApi.Repo.Migrations.CreateNotification do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :target_type, :string
      add :target_id, :integer
      add :delivery_time, :utc_datetime
      add :sent, :boolean, default: false, null: false
      add :notification_type, :string

      timestamps()
    end

    create index(:notifications, [:target_type, :target_id])
  end
end
