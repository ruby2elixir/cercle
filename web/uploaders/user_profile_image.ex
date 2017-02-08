defmodule CercleApi.UserProfileImage do
  use Arc.Definition
  use Arc.Ecto.Definition

  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  @acl :public_read

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  # @versions [:original]

  # To add a thumbnail version:
  @versions [:original, :small]

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:small, _) do
    {:convert, "-strip -thumbnail 75x75^ -gravity center -extent 75x75 -format png", :png}
  end

  # Override the persisted filenames:
  def filename(version, {file, scope}) do
    "#{version}_#{String.replace(file.file_name, ~r/\..../, "")}"
  end

  def filename(version, _) do
    version
  end

  # Override the storage directory:
  def storage_dir(version, {file, scope}) do
    "uploads/users/profile_images/#{scope.id}"
  end

  #Provide a default URL if there hasn't been a file uploaded
  def default_url(version, scope) do
    "http://www.cercle.co/images/pp_2.png"
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

  def validate({file, _}) do   
    file_extension = file.file_name |> Path.extname |> String.downcase
    Enum.member?(@extension_whitelist, file_extension)
  end
end
