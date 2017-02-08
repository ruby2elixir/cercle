defmodule CercleApi.Repo.Migrations.AddUniqueneIndexToCode do
  use Ecto.Migration

  def change do
    create index(:codes, [:code], unique: true)
  end
end
