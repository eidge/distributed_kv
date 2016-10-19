defmodule DistributedKvTest do
  use ExUnit.Case

  describe "registry_for/1" do
    test "returns different registries for different names" do
      shopping_registry = DistributedKv.registry_for("Shopping list")
      another_registry = DistributedKv.registry_for("Another")
      assert shopping_registry != another_registry
    end

    test "returns the same registry if the same name is given" do
      shopping_registry = DistributedKv.registry_for("Shopping list")
      another_registry = DistributedKv.registry_for("Shopping list")
      assert shopping_registry == another_registry
    end
  end

  describe "registries/0" do
    test "returns all registries" do
      registries = DistributedKv.registries
      assert Enum.count(registries) == Application.get_env(:distributed_kv, :number_of_registries)
    end
  end

  test "does not touch other registries if one crashes" do
    registry = DistributedKv.registry_for("one")
    another_registry = DistributedKv.registry_for("four")
    assert registry != another_registry

    Process.exit(registry, :kill)
    assert Process.alive?(registry) == false

    new_registry_for_one = DistributedKv.registry_for("one")
    assert Process.alive?(new_registry_for_one) == true
    assert registry != new_registry_for_one
  end
end
