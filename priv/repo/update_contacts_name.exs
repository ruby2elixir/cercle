import Ecto.Query
alias CercleApi.{Repo, Contact}

query = from p in Contact,
  where: is_nil(p.last_name)
contacts = Repo.all(query)

Enum.each contacts, fn (contact) ->
  splits = String.split(contact.first_name, ~r/\s+/)
  [first_name|splits] = splits
  last_name = Enum.join(splits, " ")
  changeset = Contact.changeset(contact, %{:first_name => first_name, :last_name => last_name })
  Repo.update(changeset)
end
