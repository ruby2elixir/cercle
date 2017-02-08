defmodule CercleApi.Repo.Migrations.AddRemoveuseless do
  use Ecto.Migration

  def change do
  	alter table(:contacts) do
     	remove :reward_value
     	remove :referral_phone
     	remove :status
     	remove :company_service_id
     	remove :sender_name
     	remove :sender_email
     	remove :referral_company
     	remove :send_reminder_at
     	remove :referral_comment
     	remove :manager_id
     	remove :rating
     	remove :referral_job_title
    end
    
    rename table(:contacts), :referral_name, to: :name
    rename table(:contacts), :referral_email, to: :email
    
    alter table(:organizations) do
     	remove :description
    end

    rename table(:organizations), :manager_id, to: :user_id
  end
end
