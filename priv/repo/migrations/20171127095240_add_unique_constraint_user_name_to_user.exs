defmodule CercleApi.Repo.Migrations.AddUniqueConstraintUserNameToUser do
  use Ecto.Migration
  alias CercleApi.{Repo, User}
  import Ecto.Query, only: [from: 2]

  def up do
    prepare_users
    alter table("users") do
      modify :user_name, :string, null: false
    end
    create unique_index("users", [:user_name])
  end

  def down do
    drop unique_index("users", [:user_name])
    alter table("users") do
      modify :user_name, :string, null: true
    end
  end

  defp prepare_users do
    # remove user without login
    Ecto.Query.from(
      u in User,
      where: is_nil(u.login) or u.login == ""
    ) |> Repo.delete_all

    # rename duplicate user_name -> user_name + id
    sql = """
      UPDATE users s
      SET user_name = u.user_name || u.row
      FROM( SELECT id, user_name,
       ROW_NUMBER()
       OVER(PARTITION BY user_name ORDER BY user_name asc) AS row
       FROM users) as u
      WHERE u.row > 1 and s.id = u.id
    """
    Ecto.Adapters.SQL.query!(Repo, sql, [])
    query = Ecto.Query.from(
      u in User,
      where: is_nil(u.user_name) or u.user_name == "",
      where: not(is_nil(u.login)) or not(u.login == "")
    )

    query
    |> Repo.all
    |> Enum.each(&(update_user_name(&1)))
  end

  defp update_user_name(user) do
    User.update_user_name(user)
    |> Repo.update!
  end
end
