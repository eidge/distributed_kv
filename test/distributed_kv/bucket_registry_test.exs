defmodule DistributedKv.BucketRegistryTest do
  use ExUnit.Case

  alias DistributedKv.BucketRegistry

  setup do
    {:ok, registry} = BucketRegistry.start_link
    {:ok, registry: registry}
  end

  describe "all/1" do
    test "returns empty list if there is no bucket yet", %{registry: registry} do
      assert BucketRegistry.all(registry) == []
    end

    test "returns all created buckets", %{registry: registry} do
      {:ok, _} = BucketRegistry.create(registry, "new_bucket")
      count = registry |> BucketRegistry.all |> Enum.count
      assert count == 1
    end
  end

  describe "create/2" do
    test "creates a new bucket", %{registry: registry} do
      assert {:ok, bucket} = BucketRegistry.create(registry, "new_bucket")
      assert Process.alive?(bucket)
    end

    test "returns bucket instead of creating new one if it already exists", %{registry: registry} do
      {:ok, bucket} = BucketRegistry.create(registry, "new_bucket")
      {:ok, other_bucket} = BucketRegistry.create(registry, "new_bucket")
      assert bucket == other_bucket
    end
  end

  describe "lookup/2" do
    test "returns bucket if name exists", %{registry: registry} do
      {:ok, bucket} = BucketRegistry.create(registry, "new_bucket")
      assert bucket == BucketRegistry.lookup(registry, "new_bucket")
    end

    test "returns nil if bucket for name does not exist", %{registry: registry} do
      assert nil == BucketRegistry.lookup(registry, "new_bucket")
    end
  end

  test "dead buckets are removed from the registry", %{registry: registry} do
    {:ok, bucket} = BucketRegistry.create(registry, "new_bucket")
    assert Process.alive?(bucket) == true

    Process.exit(bucket, :kill)
    assert Process.alive?(bucket) == false

    assert nil == BucketRegistry.lookup(registry, "new_bucket")
  end
end
