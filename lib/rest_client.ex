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
        Creates a new record of the resource via a HTTP POST request to
        http://apiurl.com/resources. The response is expected to be in JSON
        and the default key is "data".

        # Examples

            defmodule Test do
                api "http://test.com"
            end

            def Test.User do
              resource Test, [:id, :username, :email]
            end

        `Test.User.create {"something", "pass123"}, %Test.User{ username: "Peter Pan", email: "peter@pan123.com"}`
        will issue a HTTP POST request to `http://test.com/users` with the data
        being form-urlencoded. Say that request returns

            {
              data: {
                  id: 1,
                  username: "Peter Pan",
                  email: "peter@pan123.com"
              }
            }

        `Test.User.create/2` will return a `%Test.User` struct according to that
        data.
      """
      def create(auth, struct) do
        HTTPotion.post("#{unquote(api).url}/#{path}", basic_auth: auth,
          body: struct_to_post_body(struct), headers: [
            "Content-type": "application/x-www-form-urlencoded"
          ]).body
          |> Poison.decode!(as: %{"data" => __MODULE__})
          |> Map.get("data")
      end

      @doc """
        Deletes a record of the resource via a HTTP DELETE request to
        http://apiurl.com/resources/id. The response is expected to return a
        status code if 200, otherwise the method returns false.

        # Examples

            defmodule Test do
                api "http://test.com"
            end

            def Test.User do
              resource Test, [:id, :username, :email]
            end

        `Test.User.delete {"something", "pass123"}, "1"` will
        issue a HTTP DELETE request to `http://test.com/users/1`. Say that
        request returns a status code of 200. Then `Test.User.delete/2` will
        return true.
      """
      def delete(auth, id) do
        200 == HTTPotion.delete("#{unquote(api).url}/#{path}/#{id}",
          basic_auth: auth).status_code
      end

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

      defp struct_to_post_body(struct) do
        struct
          |> Map.to_list
          |> Keyword.delete(:__struct__)
          |> Enum.reject(fn({k, v}) -> v == nil end)
          |> Enum.map(fn({k, v}) -> "#{k}=#{v}" end)
          |> Enum.join("&")
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