defmodule CercleApi.Repo.Migrations.AddCoLogindoUsers do
  use Ecto.Migration

  def change do
		alter table(:users) do
			add :login, :string
		end
		create unique_index(:users, [:login])
  end
end
