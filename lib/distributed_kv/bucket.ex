defmodule DistributedKv.Bucket do
  use GenServer

  def start(opts \\ []) do
    GenServer.start(__MODULE__, nil, opts)
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(_) do
    initial_state = Map.new
    {:ok, initial_state}
  end

  ##########################
  #                        #
  # Client side functions  #
  #                        #
  ##########################

  @doc """
  Fetch the value in a bucket for a given key.

  Returns the value for the given key or nil if the key does not exist
  in the bucket yet.
  """
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @doc """
  Sets or overwrites the value for a given key.

  Returns :ok
  """
  def set(pid, key, value) do
    GenServer.call(pid, {:set, key, value})
  end

  ##########################
  #                        #
  # Process side functions #
  #                        #
  ##########################

  def handle_call({:get, key}, _from, state) do
    value = Map.get(state, key)
    {:reply, value, state}
  end

  def handle_call({:set, key, value}, _from, state) do
    new_state = Map.put(state, key, value)
    {:reply, :ok, new_state}
  end
end
