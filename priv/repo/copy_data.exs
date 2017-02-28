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
alias CercleApi.BoardColumn
alias CercleApi.User
import Ecto.Query

cs = CercleApi.Repo.all(Company)

Enum.each cs, fn (c) ->
    company_id = c.id
    board_params = %{:company_id => c.id }
    changeset = Board.changeset(%Board{:name => "Deals"}, board_params)
    board = CercleApi.Repo.insert!(changeset)
    steps = ["Lead in", "Contact Made", "Needs Defined", "Proposal Made", "Negotiation Started"]
    Enum.each [0,1,2,3,4], fn (index) ->
        boardcol_params = %{:board_id => board.id, :order => index, :name => Enum.at(steps, index)}
        changeset = BoardColumn.changeset(%BoardColumn{}, boardcol_params)
        board_column = CercleApi.Repo.insert!(changeset)

        query = from p in Opportunity,
            where: p.stage == ^index,   
            where: p.company_id == ^company_id
    
        opportunitinies = CercleApi.Repo.all(query)
        Enum.each opportunitinies, fn (o) ->
            changeset = Opportunity.changeset(o, %{:board_column_id => board_column.id, :board_id => board.id })
            CercleApi.Repo.update!(changeset)
        end
    end

    
end