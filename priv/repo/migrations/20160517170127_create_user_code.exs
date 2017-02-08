defmodule CercleApi.Repo.Migrations.CreateUserCode do
  use Ecto.Migration

  def change do
    create table(:user_codes) do
      add :user_id, :integer
      add :code_id, :integer

      timestamps
    end

  end
end
