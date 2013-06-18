Code.require_file "../test_helper.exs", __DIR__

defmodule Ecto.SQLTest do
  use ExUnit.Case

  import Ecto.Query.DSL
  alias Ecto.SQL

  test "from" do
    query = from(r in Repo) |> select(r.x)
    assert SQL.compile(query) == "SELECT r.x\nFROM repo AS r"

    query = from(r in Repo) |> from(r2 in Repo2) |> select(r.x)
    assert SQL.compile(query) == "SELECT r.x\nFROM repo AS r, repo2 AS r2"
  end

  test "select" do
    query = from(r in Repo) |> select({r.x, r.y})
    assert SQL.compile(query) == "SELECT r.x, r.y\nFROM repo AS r"

    query = from(r in Repo) |> select({r.x, r.y, [{r.z}]})
    assert SQL.compile(query) == "SELECT r.x, r.y, r.z\nFROM repo AS r"
  end

  test "where" do
    query = from(r in Repo) |> where(r.x != nil) |> select(r.x)
    assert SQL.compile(query) == "SELECT r.x\nFROM repo AS r\nWHERE (r.x != NULL)"

    query = from(r in Repo) |> where(r.x) |> where(r.y) |> select(r.x)
    assert SQL.compile(query) == "SELECT r.x\nFROM repo AS r\nWHERE (r.x) AND (r.y)"
  end

  # TODO: Test expression gen
end