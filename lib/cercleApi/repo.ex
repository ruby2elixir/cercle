defmodule CercleApi.Repo do
  use Ecto.Repo, otp_app: :cercleApi
  use Scrivener, page_size: 10
end
