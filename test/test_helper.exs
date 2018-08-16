ExUnit.start()

defmodule TestHelper do
  use ExUnit.Case, async: false
  alias ExponentServerSdk.Notification
  import Mock

  def with_fixture(:get!, response, fun),
    do: with_fixture({:get!, fn _url, _headers -> response end}, fun)

  def with_fixture(:post!, response, fun),
    do: with_fixture({:post!, fn _url, _options, _headers -> response end}, fun)

  def with_fixture(stub, fun) do
    with_mock Notification, [:passthrough], [stub] do
      fun.()
    end
  end

  def json_response(map, status) do
    {:ok, json} = Poison.encode(map)
    %{body: json, status_code: status}
  end
end
