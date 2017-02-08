defmodule CercleApi.Repo.Migrations.AddUserUid do
  use Ecto.Migration

  def change do
	alter table(:users) do
	  add :uid, :text
	end
  end
end
