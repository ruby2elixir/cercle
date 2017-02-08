defmodule CercleApi.Repo.Migrations.AddOrganizations do
  use Ecto.Migration

  def change do
  	create table(:organizations) do
     	add :manager_id, :integer
		  add :company_id, :integer
		  add :name ,:string
		  add :website ,:string
		  add :description , :text
     	timestamps
    end
    alter table(:rewards) do
     	add :organization_id, :integer
    end
  end
end
