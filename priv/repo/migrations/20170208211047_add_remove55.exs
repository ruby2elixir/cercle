defmodule CercleApi.Repo.Migrations.AddRemove55 do
  use Ecto.Migration

  def change do
  	alter table(:users) do
    	remove :emails
    	remove :app_id
    	remove :uid
    	remove :last_opened_company_id
    end

  end
end
