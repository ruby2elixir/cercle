defmodule CercleApi.Repo.Migrations.AddFieldsForCompanies do
  use Ecto.Migration

  def change do
  	alter table(:companies) do
  		add :admin_title, :string
  		add :nb_salesperson, :string
  	end
  end
end
