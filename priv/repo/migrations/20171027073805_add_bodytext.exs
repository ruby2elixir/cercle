defmodule CercleApi.Repo.Migrations.AddBodytext do
  use Ecto.Migration

  def change do
  	alter table(:emails) do
      add :body_text, :text
    end
  end
end
