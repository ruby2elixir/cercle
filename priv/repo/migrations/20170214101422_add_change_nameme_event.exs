defmodule CercleApi.Repo.Migrations.AddChangeNamemeEvent do
  use Ecto.Migration

  def change do
  	alter table(:timeline_events) do
     	add :metadata, :map, default: fragment("json_build_object()::jsonb")
    end
    rename table(:timeline_events), :action_type, to: :event_name
  end
end
