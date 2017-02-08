defmodule CercleApi.Repo.Migrations.AddPoremoveUseless2 do
  use Ecto.Migration

  def change do
  	drop table(:reward_participants)
  	drop table(:invoices)
  	alter table(:contacts) do
     	add :phone, :string
     	add :description, :string
    end
    alter table(:organizations) do
     	add :description, :string
    end
    alter table(:companies) do
    	remove :description2
    	remove :individual
    	remove :subtitle1
    	remove :subtitle2
    	remove :reward
    	remove :password_hash
    	remove :stripe_customer_id
    	remove :stripe_plan_id
    	remove :stripe_subscription_id
    	remove :plan_id
    	remove :admin_title
    	remove :nb_salesperson
    end
    alter table(:activities) do
    	remove :type
    end
  end
end
