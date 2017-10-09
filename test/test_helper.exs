Mailman.TestServerSupervisor.start_link
ExUnit.start

Ecto.Adapters.SQL.Sandbox.mode(CercleApi.Repo, :manual)
{:ok, _} = Application.ensure_all_started(:ex_machina)

Application.put_env(:wallaby, :base_url, CercleApi.Endpoint.url)
Application.put_env(:wallaby, :screenshot_on_failure, true)
{:ok, _} = Application.ensure_all_started(:wallaby)
