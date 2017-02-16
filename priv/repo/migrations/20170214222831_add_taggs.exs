defmodule CercleApi.Repo.Migrations.AddTaggs do
  use Ecto.Migration

  def change do
  	create table(:tags) do
      add :company_id, :integer
      add :name, :string
      timestamps
  	end
  	create table(:contacts_tags) do
    	add :contact_id, references(:contacts)
    	add :tag_id, references(:tags)
    	timestamps
  	end
  end
end
