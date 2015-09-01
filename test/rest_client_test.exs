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
      response: %{body: "{\"data\":[{\"id\":\"1\",\"email\":\"demo@test.com\",\"username\":\"Testkunde\"}],\"data_count\":\"1\"}"}
    }
  end

  test "api/1 saves the url in the module" do
    assert Test.url == "http://test.com"
  end

  test "resource/2 defines a helper for the path" do
    assert Test.User.path == "users"
  end

  test "index/1 makes the correct GET request", %{response: response} do
    with_mock HTTPotion, [get: fn(_, _) -> response end] do
      Test.User.index {"user", "pass"}

      assert called HTTPotion.get("http://test.com/users",
        basic_auth: {"user", "pass"})
    end
  end

  test "index/1 decodes the data correctly", %{response: response} do
    with_mock HTTPotion, [get: fn(_, _) -> response end] do
      assert Test.User.index({"user", "pass"}) == [%Test.User{
        id: "1",
        email: "demo@test.com",
        username: "Testkunde"
      }]
    end
  end
end
