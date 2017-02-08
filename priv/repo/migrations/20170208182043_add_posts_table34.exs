defmodule CercleApi.Repo.Migrations.AddPostsTable34 do
  use Ecto.Migration

  def change do
  	alter table(:contacts) do
     	add :job_title, :string
    end
    alter table(:timeline_events) do
     	add :company_id, :integer
    end
  end
end
