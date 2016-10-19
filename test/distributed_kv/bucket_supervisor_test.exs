defmodule DistributedKv.BucketSupervisorTest do
  use ExUnit.Case

  alias DistributedKv.BucketSupervisor

  describe "start_bucket/1" do
    test "creates a new bucket" do
      assert {:ok, _} = BucketSupervisor.start_bucket(:bucket)
    end

    test "returns the bucket if it already exists" do
      assert {:ok, pid} = BucketSupervisor.start_bucket(:bucket)
      assert {:ok, ^pid} = BucketSupervisor.start_bucket(:bucket)
    end
  end

  describe "find_or_start_bucket!/1" do
    test "returns existing bucket" do
      {:ok, bucket} = BucketSupervisor.start_bucket(:beautiful_bucket)
      assert bucket == BucketSupervisor.find_or_start_bucket!(:beautiful_bucket)
    end
  end
end
