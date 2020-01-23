defmodule ExponentServerSdk.PushNotification do
  @moduledoc """
  Provides a basic HTTP interface to allow easy communication with the Exponent Push Notification
  API, by wrapping `HTTPotion`.

  ## Examples

  Requests are made to the Exponent Push Notification API by passing in a `Map` into one
  of the `Notification` module's functions. The correct URL to the resource is inferred
  from the module name.

      ExponentServerSdk.PushNotification.push(messages)
      {:ok, %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}

  Items are returned as instances of the given module's struct. For more
  details, see the documentation for each function.
  """

  use HTTPoison.Base

  alias ExponentServerSdk.Parser
  alias ExponentServerSdk.PushMessage
  # Necessary for mocks in tests
  alias __MODULE__

  @doc """
  Send the push notification request when using a single message map
  """
  @spec push(PushMessage.t()) :: Parser.success() | Parser.error()
  def push(message) when is_map(message) do
    message
    |> PushMessage.create()
    |> PushNotification.post!("send", message)
    |> Parser.parse()
  end

  @doc """
  Send the push notification request when using a list of message maps
  """
  @spec push_list(list()) :: list(Parser.success()) | list(Parser.error())
  def push_list(messages) when is_list(messages) do
    messages
    |> PushMessage.create_from_list
    # |> Enum.chunk_every(100)
    |> push_messages_list
  end

  def push_messages_list([]), do: []

  @spec push_messages_list(list(list(PushMessage.t()))) :: list(Parser.success()) | list(Parser.error())
  def push_messages_list([head | tail]) do
    current_message = PushNotification.post!("send", head) |> Parser.parse_list()
    [ current_message | push_messages_list(tail) ]
  end

  @doc """
  Send the get notification receipts request when using a list of ids
  """
  @spec get_receipts(list()) :: Parser.success() | Parser.error()
  def get_receipts(ids) when is_list(ids) do
    PushNotification.post!("getReceipts", %{ids: ids})
    |> Parser.parse()
  end

  @doc """
  Automatically adds the correct url to each API request.
  """
  @spec process_url(String.t()) :: String.t()
  def process_url(url) do
    "https://exp.host/--/api/v2/push/" <> url
  end

  @doc """
  Automatically adds the correct headers to each API request.
  """
  @spec process_request_headers(list) :: list
  def process_request_headers(headers \\ []) do
    headers
    |> Keyword.put(:Accepts, "application/json")
    |> Keyword.put(:"Accepts-Encoding", "gzip, deflate")
    |> Keyword.put(:"Content-Encoding", "gzip")
    |> Keyword.put(:"Content-Type", "application/json")
  end

  @doc """
  Automatically process the request body using Poison JSON and GZip.
  """
  def process_request_body(body) do
    body
    |> Poison.encode!()
    |> :zlib.gzip()
  end
end
