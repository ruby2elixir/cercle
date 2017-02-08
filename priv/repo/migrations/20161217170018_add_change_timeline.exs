defmodule CercleApi.Repo.Migrations.AddChangeTimeline do
  use Ecto.Migration

  def change do
  	rename table(:timeline_events), :comment, to: :content
  	alter table(:timeline_events) do
     	add :action_type, :string, default: "comment"
     	remove :is_a_reporting
     	remove :status
    end
  end
end
