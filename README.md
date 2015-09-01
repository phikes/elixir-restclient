RestClient
==========

RestClient is a generic REST client library. It generates structs and functions
for use with APIs. I currently use it for interfacing the
[Paymill](https://developers.paymill.com/API) API from Elixir.

# Example
    defmodule Test do
        api "http://test.com"
    end

    def Test.User do
      resource Test, [:id, :username, :email]
    end

This will give you the following functions:
  * `Test.User.index/1`
  * `Test.User.update/3`
  * `Test.User.show/2`
  * `Test.User.create/2`
  * `Test.User.delete/2`

The first parameter is used to pass in authentication (currently we assume
http basic authentication), e.g.
      Test.index {"myuser", "mypass"}