defmodule DistributedKv do
  use Application

  alias DistributedKv.BucketRegistry

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(BucketRegistry, [[name: BucketRegistry]])
    ]
    opts = [strategy: :one_for_one, name: DistributedKv.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
