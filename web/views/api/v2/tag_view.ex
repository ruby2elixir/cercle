defmodule CercleApi.APIV2.TagView do
  use CercleApi.Web, :view

  def render("index.json", %{tags: tags}) do
    %{data: render_many(tags, CercleApi.APIV2.TagView, "tag.json")}
  end

  def render("show.json", %{tag: tag}) do
    %{data: render_one(tag, CercleApi.APIV2.TagView, "tag.json")}
  end

  def render("tag.json", %{tag: tag}) do
    %{id: tag.id,
      company_id: tag.company_id}
  end
end
