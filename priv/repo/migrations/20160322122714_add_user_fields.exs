defmodule CercleApi.Repo.Migrations.AddUserFields do
  use Ecto.Migration

  def change do
	alter table(:users) do
	  add :emails, :string
	  add :app_id, :text
	end

  end
end
