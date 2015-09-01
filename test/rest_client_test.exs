defmodule RestClientTest do
  use ExUnit.Case, async: false
  import Mock

  defmodule Test do
    require RestClient
    import RestClient

    api "http://test.com"
  end

  defmodule Test.User do
    require RestClient
    import RestClient

    resource Test, [:id, :username, :email]
  end

  setup do
    {
      :ok,
      index: %{body: "{\"data\":[{\"id\":\"1\",\"email\":\"demo@test.com\",\"username\":\"Testkunde\"}],\"data_count\":\"1\"}"},
      create: %{body: "{\"data\":{\"id\":\"1\",\"email\":\"abc@def.com\", \"username\": \"harald\"}}"},
      show: %{body: "{\"data\":{\"id\":\"1\",\"email\":\"abc@def.com\", \"username\": \"harald\"}}"}
    }
  end

  test "api/1 saves the url in the module" do
    assert Test.url == "http://test.com"
  end

  test "resource/2 defines a helper for the path" do
    assert Test.User.path == "users"
  end

  test "index/1 makes the correct GET request", %{index: response} do
    with_mock HTTPotion, [get: fn(_, _) -> response end] do
      Test.User.index {"user", "pass"}

      assert called HTTPotion.get("http://test.com/users",
        basic_auth: {"user", "pass"})
    end
  end

  test "index/1 decodes the data correctly", %{index: response} do
    with_mock HTTPotion, [get: fn(_, _) -> response end] do
      assert Test.User.index({"user", "pass"}) == [%Test.User{
        id: "1",
        email: "demo@test.com",
        username: "Testkunde"
      }]
    end
  end

  test "delete/2 makes the correct DELETE request" do
    with_mock HTTPotion, [delete: fn(_, _) -> %{status_code: 200} end] do
      Test.User.delete {"user", "pass"}, "1"

      assert called HTTPotion.delete("http://test.com/users/1",
        basic_auth: {"user", "pass"})
    end
  end

  test "delete/2 signals success" do
    with_mock HTTPotion, [delete: fn(_, _) -> %{status_code: 200} end] do
      assert Test.User.delete({"user", "pass"}, "1")
    end
  end

  test "delete/2 signals failure" do
    with_mock HTTPotion, [delete: fn(_, _) -> %{status_code: 404} end] do
      assert !Test.User.delete({"user", "pass"}, "1")
    end
  end

  test "create/2 makes the correct POST request", %{create: response} do
    with_mock HTTPotion, [post: fn(_, _) -> response end] do
      Test.User.create {"user", "pass"}, %Test.User{ email: "abc@def.com",
        username: "harald" }

      assert called HTTPotion.post("http://test.com/users",
        basic_auth: {"user", "pass"},
        body: "email=abc@def.com&username=harald",
        headers: [
            "Content-type": "application/x-www-form-urlencoded"
          ])
    end
  end

  test "create/2 returns the created record", %{create: response} do
    with_mock HTTPotion, [post: fn(_, _) -> response end] do
      assert Test.User.create({"user", "pass"}, %Test.User{ email: "abc@def.com",
        username: "harald" }) == %Test.User{ email: "abc@def.com",
        username: "harald", id: "1" }
    end
  end

  test "show/2 makes the correct GET request", %{show: response} do
    with_mock HTTPotion, [get: fn(_, _) -> response end] do
      Test.User.show {"user", "pass"}, "1"

      assert called HTTPotion.get("http://test.com/users/1",
        basic_auth: {"user", "pass"})
    end
  end

  test "show/2 returns the correct record", %{show: response} do
    with_mock HTTPotion, [get: fn(_, _) -> response end] do
      assert Test.User.show({"user", "pass"}, "1") == %Test.User{
        id: "1",
        username: "harald",
        email: "abc@def.com"
      }
    end
  end
end
