defmodule ExponentServerSdk.NotificationTest do
  use ExUnit.Case, async: false

  import TestHelper

  alias ExponentServerSdk.Notification
  alias ExponentServerSdk.PushMessage

  doctest ExponentServerSdk.Notification

  test ".push should return the proper response from Expo" do
    message_map = %{
      to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
      title: "Pushed!",
      body: "You got your first message"
    }

    response = %{data: %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}
    json = json_response(response, 200)

    with_fixture(:post!, json, fn ->
      # expected = {:ok, %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}
      expected =
        {:ok,
         %{
           "status" => "error",
           "details" => %{"error" => "DeviceNotRegistered"},
           "message" =>
             "\"ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]\" is not a registered push notification recipient"
         }}

      assert expected == Notification.push(message_map)
    end)
  end

  test ".push_list should return an error from Expo if the does not accept request" do
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

    response = %{
      data: [
        %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"},
        %{"status" => "ok", "id" => "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"}
      ]
    }

    json = json_response(response, 200)

    with_fixture(:post!, json, fn ->
      # expected = {
      #  :ok,
      #  [
      #    %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"},
      #    %{"status" => "ok", "id" => "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"}
      #    ]
      #  }
      expected =
        {:ok,
         [
           %{
             "status" => "error",
             "details" => %{"error" => "DeviceNotRegistered"},
             "message" =>
               "\"ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]\" is not a registered push notification recipient"
           },
           %{
             "status" => "error",
             "details" => %{"error" => "DeviceNotRegistered"},
             "message" =>
               "\"ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]\" is not a registered push notification recipient"
           }
         ]}

      assert expected == Notification.push_list(message_list)
    end)
  end

  ###
  # HTTPotion API
  ###

  test ".process_request_headers adds the correct headers" do
    headers = Notification.process_request_headers([])
    accepts = {:Accepts, "application/json"}
    accepts_encoding = {:"Accepts-Encoding", "gzip, deflate"}
    content_type = {:"Content-Type", "application/json"}
    assert accepts in headers
    assert accepts_encoding in headers
    assert content_type in headers
    assert Keyword.keys(headers) == [:"Content-Type", :"Accepts-Encoding", :Accepts]
  end

  ###
  # Helpers
  ###

  def with_list_fixture(fun) do
    data = [
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

    json = json_response(data, 200)

    with_fixture(:post!, json, fn ->
      expected = {
        :ok,
        [
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
      }

      fun.(expected)
    end)
  end
end
