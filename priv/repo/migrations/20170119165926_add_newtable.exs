defmodule CercleApi.Repo.Migrations.AddNewtable do
  use Ecto.Migration

  def change do
  	create table(:activities) do
  		add :type, :string
		add :due_date, :datetime
		add :is_done, :boolean, default: false
		add :title, :string
		add :company_id, :integer
		add :contact_id, :integer
		add :user_id, :integer
		timestamps
  	end


  	create table(:opportunities) do
  		add :name, :string
  		add :stage, :integer, default: 0
  		add :status, :integer, default: 0
  		add :main_contact_id, :integer
  		add :contact_ids, {:array, :integer}
  		add :user_id, :integer
  		add :company_id, :integer
  		timestamps
  	end
  end
end
