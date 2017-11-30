defmodule CercleApi.Repo.Migrations.AddUniqueIndexUsernameToUser do
  use Ecto.Migration
  alias CercleApi.{Repo, User}
  import Ecto.Query, only: [from: 2]

  def up do
    if Mix.env != :test, do: prepare_users
    alter table("users") do
      modify :username, :string, null: false
    end
    create unique_index("users", [:username])
  end

  def down do
    drop unique_index("users", [:username])
    alter table("users") do
      modify :username, :string, null: true
    end
  end

  defp prepare_users do

    # rename duplicate user_name -> user_name + id
    sql = """
      UPDATE users s
      SET username = u.username || u.row
      FROM( SELECT id, username,
       ROW_NUMBER()
       OVER(PARTITION BY username ORDER BY username asc) AS row
       FROM users) as u
      WHERE u.row > 1 and s.id = u.id
    """
    Ecto.Adapters.SQL.query!(Repo, sql, [])
    query = Ecto.Query.from(
      u in User,
      where: is_nil(u.username) or u.username == "",
      where: not(is_nil(u.login)) or not(u.login == "")
    )

    query
    |> Repo.all
    |> Enum.each(&(update_user_name(&1)))
  end


  defp update_user_name(user) do
    IO.puts "user id: #{user.id}"
    User.update_user_name(user)
    |> Repo.update!
  end
end
