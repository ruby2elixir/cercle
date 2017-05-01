defmodule CercleApi.OpportunityAttachmentFile do
  @moduledoc """
  Upload Opportunity Attachments
  """

  use Arc.Definition
  use Arc.Ecto.Definition

  @acl :public_read

  @versions [:original, :thumb]

  # Whitelist file extensions:
  # def validate({file, _}) do
  #   ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  # end

  # Define a thumbnail transformation:
  def transform(:thumb, {file, _}) do
    if Enum.member?(~w(.jpg .jpeg .gif .png), Path.extname(file.file_name)) do
      {:convert, "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png", :png}
    else
      :noaction
    end
  end

  # Override the persisted filenames:
  def filename(version, {file, scope}) do
    "#{version}_#{String.replace(file.file_name, ~r/\..../, "")}"
  end

  def filename(version, _) do
    version
  end

  # # Override the storage directory:
  def storage_dir(version, {file, scope}) do
    "uploads/opportunities/attachments/#{scope.id}"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: Plug.MIME.path(file.file_name)]
  # end
end
