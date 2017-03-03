defmodule CercleApi.APIV2.TagsController do

  require Logger
  use CercleApi.Web, :controller

  alias CercleApi.Tag

  def index(conn, params) do
    q = Map.get(params, "q")
    company_id = Map.get(params, "company_id")
    query = Tag

    if q do
      query = from tag in query,
        where: like(tag.name, ^"#{q}%")
    end

    if company_id do
      query = from tag in query,
        where: tag.company_id == ^company_id
    end

    tags = Repo.all(query)

    render(conn, "index.json", tags: tags)
  end

end
