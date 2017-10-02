defmodule CercleApi.FeatureCase do
  use ExUnit.CaseTemplate


  using do
    quote do
      use Wallaby.DSL
      import Wallaby.Query

      alias CercleApi.Repo
      import Ecto
      import Ecto.Changeset
      import Ecto.Query

      import CercleApi.Router.Helpers
      import CercleApi.Factory
      import CercleApi.Repo
      import CercleApi.TestHelpers
      import CercleApi.IntegrationHelpers
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(CercleApi.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(CercleApi.Repo, {:shared, self()})
    end

    metadata = Phoenix.Ecto.SQL.Sandbox.metadata_for(CercleApi.Repo, self())
    {:ok, session} = Wallaby.start_session(metadata: metadata)
    {:ok, session: session}
  end
end
