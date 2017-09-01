defmodule CercleApi.Repo.Migrations.CreateUserCompany do
  use Ecto.Migration

  def up do
    create table(:users_companies) do
      add :user_id, references(:users, on_delete: :nothing)
      add :company_id, references(:companies, on_delete: :nothing)

      timestamps()
    end
    create index(:users_companies, [:user_id])
    create index(:users_companies, [:company_id])
    execute """
      INSERT INTO users_companies(user_id, company_id, inserted_at, updated_at)
        SELECT id as user_id, company_id, now() as inserted_at, now() as updated_at
        FROM users WHERE company_id is not null;

    """
  end

  def down do
    drop table(:users_companies)
  end
end
