defmodule CercleApi.Repo.Migrations.AddPostsTabl56 do
  use Ecto.Migration

  def change do
  	alter table(:contacts) do
  		modify :description, :text
	end
	
	alter table(:organizations) do
  		modify :description, :text
	end
  end
end
