defmodule CercleApi.Repo.Migrations.AddDescriptionToOpportunity do
  use Ecto.Migration

  def change do
  	alter table(:opportunities) do
     	add :description, :text
    end

  end
end
