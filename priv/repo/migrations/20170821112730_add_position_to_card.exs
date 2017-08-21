defmodule CercleApi.Repo.Migrations.AddPositionToCard do
  use Ecto.Migration

  def change do
    alter table(:cards) do
      add :position, :integer, default: 0
    end
  end
end
