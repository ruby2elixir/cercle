defmodule CercleApi.Repo.Migrations.AddFieldsToUsers2 do
  use Ecto.Migration

  def change do
  	drop table(:company_benifits)
  	drop table(:company_services)
  	drop table(:codes)
  	drop table(:user_connections)
  end
end
