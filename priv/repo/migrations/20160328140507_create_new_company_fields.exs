defmodule CercleApi.Repo.Migrations.CreateNewCompanyFields do
  use Ecto.Migration

  def change do
	alter table(:companies) do
	  add :subtitle1, :text
	  add :subtitle2, :text
	  add :admin_email, :string
	  add :image_url, :text
	end
  end
end
