defmodule GanyuTest do
  use ExUnit.Case
  doctest Ganyu

  test "checks if it works" do
    conn = conn(:get, "/v1/status")

    assert conn.status == 200
  end
end
