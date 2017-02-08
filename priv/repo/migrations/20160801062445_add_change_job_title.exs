defmodule CercleApi.Repo.Migrations.AddChangeJobTitle do
  use Ecto.Migration

  def change do
  	rename table(:users), :job_title, to: :name
  end
end
