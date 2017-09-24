defmodule CercleApi.Repo.Migrations.RemoveMainContactIdFromCard do
  use Ecto.Migration

  def up do
    alter table(:cards) do
      remove :main_contact_id
    end
  end

  def down do
    alter table(:cards) do
      add :main_contact_id, :integer
    end
  end
end
