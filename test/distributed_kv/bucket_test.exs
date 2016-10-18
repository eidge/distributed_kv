defmodule DistributedKv.BucketTest do
  use ExUnit.Case

  alias DistributedKv.Bucket

  setup do
    {:ok, bucket} = Bucket.start_link
    {:ok, bucket: bucket}
  end

  describe "get/2" do
    setup %{bucket: bucket} do
      assert :ok == Bucket.set(bucket, :key, :value)
      :ok
    end

    test "returns value for key", %{bucket: bucket} do
      assert Bucket.get(bucket, :key) == :value
    end

    test "returns nil if key does not exist", %{bucket: bucket} do
      assert Bucket.get(bucket, :term) == nil
    end
  end

  describe "set/3" do
    test "sets value for a given key", %{bucket: bucket} do
      assert nil == Bucket.get(bucket, :key)
      assert :ok == Bucket.set(bucket, :key, :value)
      assert :value == Bucket.get(bucket, :key)
    end

    test "overwrites value for a given key", %{bucket: bucket} do
      assert :ok == Bucket.set(bucket, :key, :value)
      assert :value == Bucket.get(bucket, :key)

      assert :ok == Bucket.set(bucket, :key, :another_value)
      assert :another_value == Bucket.get(bucket, :key)
    end
  end
end
