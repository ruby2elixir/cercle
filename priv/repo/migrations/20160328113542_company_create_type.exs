defmodule CercleApi.Repo.Migrations.CompanyCreateType do
  use Ecto.Migration

  def change do
	alter table(:companies) do
	  add :individual, :boolean, default: false
	end
  end
end