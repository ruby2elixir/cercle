defmodule CercleApi.Repo.Migrations.AddBoards do
  use Ecto.Migration

  def change do
  	create table(:boards) do
      add :name, :string
      add :company_id, :integer
      timestamps
  	end

    create table(:boards_columns) do
      add :name, :string
      add :board_id, :integer
      add :order, :integer
      timestamps
    end

    alter table(:opportunities) do
     	add :board_id, :integer
      add :board_column_id, :integer
    end

  end
end
