defmodule CercleApi.Repo.Migrations.AddNewFieldsToRewards do
  use Ecto.Migration

  def change do
  	alter table(:rewards) do
      add :company_service_id, :integer
      add :sender_name, :string
      add :sender_email, :string
      add :referral_email, :string
    end
    rename table(:rewards), :user_name, to: :referral_name
    rename table(:rewards), :email, to: :referral_phone
  end
end
