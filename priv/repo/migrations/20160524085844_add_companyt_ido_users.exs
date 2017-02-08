defmodule CercleApi.Repo.Migrations.AddCompanytIdoUsers do
  use Ecto.Migration

  def change do
		alter table(:users) do
			add :company_id, :integer
		end
  end
end
