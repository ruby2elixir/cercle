defmodule CercleApi.Repo.Migrations.CreateOpportunityAttachment do
  use Ecto.Migration

  def change do
    create table(:opportunity_attachments) do
      add :attachment, :string
      add :opportunity_id, references(:opportunities, on_delete: :nothing)

      timestamps()
    end
    create index(:opportunity_attachments, [:opportunity_id])

  end
end
