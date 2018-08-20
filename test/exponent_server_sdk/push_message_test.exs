defmodule ExponentServerSdk.PushMessageTest do
  use ExUnit.Case

  import ExponentServerSdk.PushMessage

  alias ExponentServerSdk.PushMessage

  doctest ExponentServerSdk.PushMessage

  test ".create should encode the Map into the PushMessage struct" do
    message_map = %{
      to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
      title: "Pushed!",
      body: "You got your first message"
    }

    message = %PushMessage{
      badge: nil,
      body: "You got your first message",
      channelId: nil,
      data: nil,
      expiration: nil,
      priority: "default",
      sound: "default",
      title: "Pushed!",
      to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
      ttl: 0
    }

    assert message == create(message_map)
  end

  test ".create_from_list should encode the List of Maps into the PushMessage struct and return as chunked List of 100's" do
    message_list = [
      %{
        to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
        title: "Pushed!",
        body: "You got your first message"
      },
      %{
        to: "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]",
        title: "Pushed Again!",
        body: "You got your second message"
      }
    ]

    messages = [
      [
        %PushMessage{
          badge: nil,
          body: "You got your first message",
          channelId: nil,
          data: nil,
          expiration: nil,
          priority: "default",
          sound: "default",
          title: "Pushed!",
          to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
          ttl: 0
        },
        %PushMessage{
          badge: nil,
          body: "You got your second message",
          channelId: nil,
          data: nil,
          expiration: nil,
          priority: "default",
          sound: "default",
          title: "Pushed Again!",
          to: "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]",
          ttl: 0
        }
      ]
    ]

    assert messages == create_from_list(message_list)
  end

  test ".create_receipt_id_list should return a validated list of ids into a map" do
    ids = ["XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"]

    assert ids == create_receipt_id_list(ids)
  end

  # test ".validate_push_token should ensure a valid token is provided" do
  #  message = %PushMessage{
  #    badge: nil,
  #    body: "You got your first message",
  #    channelId: nil,
  #    data: nil,
  #    expiration: nil,
  #    priority: "default",
  #    sound: "default",
  #    title: "Pushed!",
  #    to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
  #    ttl: 0
  #  }
  #
  #  assert true == validate_push_token(message)
  # end
end
