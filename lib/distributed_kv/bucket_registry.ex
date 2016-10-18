defmodule DistributedKv.BucketRegistry do
  use GenServer

  alias DistributedKv.Bucket

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(_) do
    initial_state = %{refs: %{}, buckets: %{}}
    {:ok, initial_state}
  end

  @doc """
  Returns all existing buckets in the registry in the form of
  [{bucket_name, bucket_pid}, ...]
  """
  def all(pid) do
    GenServer.call(pid, :all)
  end

  @doc """
  Creates a new bucket if one does not exist for the given name.

  If a bucket with that name exists, it is returned instead.
  """
  def create(pid, name) do
    GenServer.call(pid, {:create, name})
  end

  @doc """
  Returns bucket for the given name or nil if it doesn't exist
  """
  def lookup(pid, name) do
    GenServer.call(pid, {:lookup, name})
  end

  def handle_call(:all, _, state = %{buckets: buckets}) do
    bucket_list = Enum.to_list(buckets)
    {:reply, bucket_list, state}
  end

  def handle_call({:create, name}, _, state = %{refs: refs, buckets: buckets}) do
    bucket = Map.get(buckets, name)

    if bucket do
      {:reply, {:ok, bucket}, state}
    else
      {:ok, bucket} = Bucket.start
      ref = Process.monitor(bucket)
      new_refs = Map.put(refs, ref, name)
      new_buckets = Map.put(refs, name, bucket)
      {:reply, {:ok, bucket}, %{refs: new_refs, buckets: new_buckets}}
    end
  end

  def handle_call({:lookup, name}, _, state = %{buckets: buckets}) do
    {:reply, Map.get(buckets, name), state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    {name, refs} = Map.pop(state.refs, ref)
    buckets = Map.delete(state.buckets, name)
    {:noreply, %{state | refs: refs, buckets: buckets}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
