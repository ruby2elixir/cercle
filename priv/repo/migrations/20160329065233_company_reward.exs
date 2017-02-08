defmodule CercleApi.Repo.Migrations.CompanyReward do
  use Ecto.Migration

 def change do
	alter table(:companies) do
	  add :reward, :string
	end
  end
end