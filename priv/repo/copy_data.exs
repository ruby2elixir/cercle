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
alias CercleApi.Opportunity
alias CercleApi.Company
alias CercleApi.Board

cs = CercleApi.Repo.all(Company)

Enum.each cs, fn (c) ->
    company_id = c.id
    board_params = %{:company_id => c.id }
    changeset = Board.changeset(%Board{}, board_params)
    board = CercleApi.Repo.insert!(changeset)


    query = from p in Opportunity,
        where: p.company_id == ^company_id

    opportunitinies = CercleApi.Repo.all(query)
	Enum.each opportunitinies, fn (o) ->
		
	end

    #user_params = %{:contact_ids => [u.main_contact_id] }
    #changeset = Opportunity.changeset(u, user_params)
    #CercleApi.Repo.update(changeset)
end

#organizations = CercleApi.Repo.all(Organization)
#Enum.each organizations, fn (o) ->
#	user_params = %{:name => o.data["cercle_name"], :description => o.data["cercle_description"], :website => o.data["cercle_url"]  }
#	changeset = Organization.changeset(o, user_params)
#	CercleApi.Repo.update(changeset)
#end
#