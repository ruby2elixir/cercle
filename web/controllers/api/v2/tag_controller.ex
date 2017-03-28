defmodule CercleApi.APIV2.TagController do

  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.Tag

  plug Guardian.Plug.EnsureAuthenticated

  def index(conn, params) do
  	user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id

    q = Map.get(params, "q")
    query = Tag

    if q do
      query = from tag in query,
        where: tag.company_id == ^company_id,
        where: like(tag.name, ^"#{q}%")
    end

    tags = Repo.all(query)
    render(conn, "index.json", tags: tags)
  end

  def create(conn, %{"tags" => %{"name" => tag_name}}) do
  	user = Guardian.Plug.current_resource(conn)
    company_id = user.company_id

    tag = Repo.get_by(Tag, name: tag_name, company_id: company_id) ||
      Repo.insert!(%Tag{name: tag_name, company_id: company_id})
    render(conn, "show.json", tag: tag)
  end
end
