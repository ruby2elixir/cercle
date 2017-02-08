defmodule CercleApi.Repo.Migrations.AddJobTitleToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :job_title, :string, limit: 100
    end
  end
end
