defmodule DistributedKv do
  use Application

  import Supervisor.Spec

  alias DistributedKv.BucketSupervisor

  @opts [strategy: :one_for_one, name: DistributedKv.Supervisor]
  @api_port Application.get_env :distributed_kv, :api_port

  def start(_type, _args) do
    children = [bucket_supervisor_spec, api_supervisor_spec]
    Supervisor.start_link(children, @opts)
  end

  defp bucket_supervisor_spec do
    supervisor(BucketSupervisor, [])
  end

  defp api_supervisor_spec do
    Plug.Adapters.Cowboy.child_spec(:http, Web.API, [], [port: @api_port])
  end
end
