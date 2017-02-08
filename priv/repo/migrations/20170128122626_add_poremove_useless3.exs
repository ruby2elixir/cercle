defmodule CercleApi.Repo.Migrations.AddPoremoveUseless3 do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
    	remove :admin_email
    	remove :admin_name
    	remove :image
    	remove :admin_phone
    	remove :default_language
    	remove :authentication_required
    	remove :app_secret_key
    end
    rename table(:companies), :description1, to: :description
  end
end
