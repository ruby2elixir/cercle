defmodule CercleApi.Repo.Migrations.AddFijobTitle do
  use Ecto.Migration

  def change do
  	alter table(:contacts) do
     	add :referral_job_title, :string
    end
  end
end
