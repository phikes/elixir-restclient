defmodule RestClient do
  @moduledoc """
    Provides functions to encapsulate a REST API into Elixir modules and
    structs.

    # Examples

        defmodule Test do
            api "http://test.com"
        end

        def Test.User do
          resource Test, [:id, :username, :email]
        end

    This will give you the following function: `Test.User.index/1`.

    The first parameter is used to pass in authentication (currently we assume
    http basic authentication), e.g.
        Test.index {"myuser", "mypass"}
  """

  @doc """
    This marks the module as base module for the API.

    # Examples

      defmodule Test do
          api "http://test.com"
      end

    This is needed for the resources you subsequently define to be able to
    retrieve the API's base url.
  """
  defmacro api(url) do
    quote do
      def url do
        unquote url
      end
    end
  end

  defmacro resource(api, fields) do
    quote do
      defstruct unquote(fields)

      @doc """
        Retrieves all records of the resource via a HTTP GET request to
        http://apiurl.com/resources. The response is expected to be in JSON
        and the default key is "data".

        # Examples

            defmodule Test do
                api "http://test.com"
            end

            def Test.User do
              resource Test, [:id, :username, :email]
            end

        `Test.User.index {"something", "pass123"}` will
        issue a HTTP GET request to `http://test.com/users`. Say that request
        returns

            {
              data: [
                {
                  id: 1,
                  username: "Peter Pan",
                  email: "peter@pan123.com"
                },
                {
                  id: 2,
                  username: "Petra Paniol",
                  email: "petra@paniol.com"
                }
              ]
            }

        `Test.User.index/1` will return an array of `%Test.User` structs
        according to that data.
      """
      def index(auth) do
        HTTPotion.get("#{unquote(api).url}/#{path}", basic_auth: auth).body
          |> Poison.decode!(as: %{"data" => [__MODULE__]})
          |> Map.get("data")
      end

      @doc """
        The path for this resource. It defaults to the pluralized,
        downcased last part of the module, e.g. "Test.User" becomes "users".

        # Example

          defmodule Test do
              api "http://test.com"
          end

          def Test.User do
            resource Test, [:id, :username, :email]
          end

          Test.User.default_path == "users"
      """
      def path do
        Regex.run(~r/(?<=\.)[A-Za-z]*$/, Atom.to_string(__MODULE__))
          |> List.first
          |> String.downcase
          |> Inflex.pluralize
      end
    end
  end
end