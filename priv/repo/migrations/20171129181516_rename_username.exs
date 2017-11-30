defmodule CercleApi.Repo.Migrations.RenameUsername do
  use Ecto.Migration

  def up do
    drop unique_index("users", [:user_name])
    alter table("users") do
      modify :user_name, :string, null: true
    end

    rename table("users"), :user_name, to: :full_name
    rename table("users"), :name, to: :username
  end

  def down do
    rename table("users"), :full_name, to: :user_name
    rename table("users"), :username, to: :name
  end
end
