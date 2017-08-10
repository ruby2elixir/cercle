defmodule CercleApi.Repo.Migrations.AddNotificationSettingToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :notification, :boolean, default: false
    end
  end
end
