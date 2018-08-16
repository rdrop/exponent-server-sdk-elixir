defmodule ExponentServerSdk.Parser do
  @moduledoc """
  A JSON parser tuned specifically for Expo Push Notification API responses. Based on Poison's
  excellent JSON decoder.
  """

  @type http_status_code :: number
  @type success :: {:ok, map}
  @type success_list :: {:ok, [map]}
  @type error :: {:error, String.t(), http_status_code}

  @type parsed_response :: success | error
  @type parsed_list_response :: success_list | error

  @doc """
  Parse a response expected to contain a single Map

  ## Examples

  It will parse into a map. with the message response status

      iex> response = %{body: "{\\"data\\": {\\"status\\": \\"ok\\", \\"id\\": \\"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX\\"}}", status_code: 200}
      iex> return_value = ExponentServerSdk.Parser.parse(response)
      iex> return_value
      {:ok, %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}
  """
  @spec parse(HTTPoison.Response.t()) :: success | error
  def parse(response) do
    handle_errors(response, fn body ->
      {:ok, json} = Poison.decode(body)
      json["data"]
    end)
  end

  @doc """
  Parse a response expected to contain a list of Maps

  ## Examples

  It will parse into a list of maps with the message response status.

      iex> response = %{body: "{ \\"data\\": [{\\"status\\": \\"ok\\", \\"id\\": \\"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX\\"}, {\\"status\\": \\"ok\\", \\"id\\": \\"YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY\\"}] }", status_code: 200}
      iex> return_value = ExponentServerSdk.Parser.parse_list(response)
      iex> return_value
      {:ok, [%{"id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", "status" => "ok"}, %{"id" => "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY", "status" => "ok"}]}
  """
  @spec parse_list(HTTPoison.Response.t()) :: success_list | error
  def parse_list(response) do
    handle_errors(response, fn body ->
      {:ok, json} = Poison.decode(body)
      json["data"]
    end)
  end

  # @spec handle_errors(response, ((String.t) -> any)) :: success | success_delete | error
  defp handle_errors(response, fun) do
    case response do
      %{body: body, status_code: status} when status in [200, 201] ->
        {:ok, fun.(body)}

      %{body: _, status_code: 204} ->
        :ok

      %{body: body, status_code: status} ->
        {:ok, json} = Poison.decode(body)
        {:error, json["errors"], status}
    end
  end
end
