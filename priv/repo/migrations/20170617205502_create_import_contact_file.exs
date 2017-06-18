defmodule CercleApi.Repo.Migrations.CreateImportContactFile do
  use Ecto.Migration

  def change do
    create table(:import_contact_files) do
      add :content, :jsonb
      add :content_type, :string
      add :status, :string, default: "init"
      add :uuid, :string, null: false
      timestamps()
    end

    create unique_index(:import_contact_files, [:uuid])

  end
end
