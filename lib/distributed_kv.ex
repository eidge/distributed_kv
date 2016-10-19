defmodule DistributedKv do
  use Application

  alias DistributedKv.BucketRegistry

  @number_of_registries Application.get_env(:distributed_kv, :number_of_registries)

  def start(_type, _args) do
    children = Enum.map(1..4, &bucket_worker_spec/1)
    opts = [strategy: :one_for_one, name: DistributedKv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp bucket_worker_spec(index) do
    import Supervisor.Spec, warn: false
    name = registry_name(index)
    worker(BucketRegistry, [[name: name]], id: name)
  end

  @doc """
  Returns the pid of the registry where a given name might reside.

  This is used to distribute load for multiple registries so that
  a single registry doesn't become a bottleneck.

  To known whether a given bucket name exists or not, the BucketRegistry
  functions should be called, as registry_for/1 gives no guarantees as
  to whether that bucket exists or not. The only guarantee is that if
  it exists, it will reside in the returned BucketRegistry.
  """
  def registry_for(name) do
    registry = name
    |> registry_number
    |> registry_name
    |> Process.whereis

    case registry do
      nil ->
        :timer.sleep(10)
        registry_for(name)
      pid -> pid
    end
  end

  defp registry_number(name) do
    :erlang.phash2(name, @number_of_registries) + 1
  end

  defp registry_name(index) when is_number(index) do
    :"BucketRegistry#{index}"
  end

  @doc """
  Returns all alive registries
  """
  def registries do
    1..4
    |> Enum.map(&registry_name/1)
    |> Enum.map(&Process.whereis/1)
    |> Enum.reject(&(&1 == nil))
  end
end
