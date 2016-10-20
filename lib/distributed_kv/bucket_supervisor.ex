defmodule DistributedKv.BucketSupervisor do
  use Supervisor

  alias DistributedKv.Bucket

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(Bucket, [], restart: :transient)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def find_or_start_bucket!(name) do
    case bucket = find(name) do
      nil ->
        {:ok, bucket} = start_bucket(name)
        bucket
      bucket ->
        bucket
    end
  end

  def start_bucket(name) do
    case Supervisor.start_child(__MODULE__, [[name: name]]) do
      {:ok, pid} ->
        :yes = :global.register_name(name, pid)
        {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      error -> error
    end
  end

  defp find(name) do
    case :global.whereis_name(name) do
      :undefined -> nil
      pid -> pid
    end
  end
end
