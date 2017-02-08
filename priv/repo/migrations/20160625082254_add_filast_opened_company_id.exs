defmodule CercleApi.Repo.Migrations.AddFilastOpenedCompanyId do
  use Ecto.Migration

  def change do
  	alter table(:users) do
      add :last_opened_company_id, :integer
    end
  end
end
