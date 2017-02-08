# Script for populating the database. You can run it as:
#
#     mix run priv/repo/copy_data.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CercleApi.Repo.insert!(%CercleApi.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias CercleApi.Contact
alias CercleApi.Organization

contacts = CercleApi.Repo.all(Contact)
Enum.each contacts, fn (u) ->
	if !is_nil(u.data) do
    	user_params = %{:email => u.data["cercle_email"], :name => u.data["cercle_name"] , :phone => u.data["cercle_phone"], :description => u.data["cercle_description"] , :job_title => u.data["cercle_job_title"]  }
    	changeset = Contact.changeset(u, user_params)
    	CercleApi.Repo.update(changeset)
	end	
end

organizations = CercleApi.Repo.all(Organization)
Enum.each organizations, fn (o) ->
	user_params = %{:name => o.data["cercle_name"], :description => o.data["cercle_description"], :website => o.data["cercle_url"]  }
	changeset = Organization.changeset(o, user_params)
	CercleApi.Repo.update(changeset)
end
