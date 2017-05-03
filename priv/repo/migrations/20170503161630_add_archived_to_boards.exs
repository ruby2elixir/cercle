defmodule CercleApi.Repo.Migrations.AddArchivedToBoards do
  use Ecto.Migration

  def change do
    alter table(:boards) do
      add :archived, :boolean, default: false
    end
  end
end
