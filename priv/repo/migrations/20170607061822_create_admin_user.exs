defmodule CercleApi.Repo.Migrations.CreateAdminUser do
  use Ecto.Migration

  def up do
    create table(:admin_users) do
      add :name, :string
      add :email, :string

      timestamps()
    end
    create unique_index(:admin_users, [:email])
  end

  def down do
    drop table(:admin_users)
  end
end
