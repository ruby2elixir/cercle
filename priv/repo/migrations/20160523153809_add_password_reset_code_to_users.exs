defmodule CercleApi.Repo.Migrations.AddPasswordResetCodeToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_reset_code, :string
    end
  end
end
