defmodule CercleApi.Repo.Migrations.RenameOpportunity do
  use Ecto.Migration

  def change do
    rename table(:opportunities), to: table(:cards)
    rename table(:opportunity_attachments), to: table(:card_attachments)

    rename table(:card_attachments), :opportunity_id, to: :card_id
    rename table(:activities), :opportunity_id, to: :card_id
    rename table(:timeline_events), :opportunity_id, to: :card_id
  end
end
