defmodule ExponentServerSdk.PushNotificationTest do
  use ExUnit.Case, async: false

  import TestHelper

  alias ExponentServerSdk.PushMessage
  alias ExponentServerSdk.PushNotification

  doctest ExponentServerSdk.PushNotification

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
      expected = {:ok, %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}
        # {:ok,
        #  %{
        #    "status" => "error",
        #    "details" => %{"error" => "DeviceNotRegistered"},
        #    "message" =>
        #      "\"ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]\" is not a registered push notification recipient"
        #  }}


      assert expected == PushNotification.push(message_map)
    end)
  end

  test ".push_list should return the proper response from Expo" do
    message_list = [
      %{
        to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
        title: "Pushed!",
        body: "You got your first message",
        data: %{}
      },
      %{
        to: "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]",
        title: "Pushed Again!",
        body: "You got your second message",
        data: %{}
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
      expected = [
        ok: [
          %{
            "details" => %{
              "error" => "DeviceNotRegistered"
            },
            "message" => "\"ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]\" is not a registered push notification recipient",
            "status" => "error"
          },
          %{
            "details" => %{
              "error" => "DeviceNotRegistered"
            },
            "message" => "\"ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]\" is not a registered push notification recipient",
            "status" => "error"
          }
        ]
      ]

      assert expected == PushNotification.push_list(message_list)
    end)
  end

  test ".get_receipts should return the proper response from Expo" do
    ids = ["XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"]

    response = %{
      data: %{
        "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX": %{status: "ok"},
        "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY": %{status: "ok"}
      }
    }

    json = json_response(response, 200)

    with_fixture(:post!, json, fn ->
      # expected =
      #  {:ok,
      #   %{
      #     "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX" => %{"status" => "ok"},
      #     "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY" => %{"status" => "ok"}
      #   }}
      expected = {:ok, %{}}

      assert expected == PushNotification.get_receipts(ids)
    end)
  end

  ###
  # HTTPotion API
  ###

  test ".process_request_headers adds the correct headers" do
    headers = PushNotification.process_request_headers([])
    accepts = {:Accepts, "application/json"}
    accepts_encoding = {:"Accepts-Encoding", "gzip, deflate"}
    content_encoding = {:"Content-Encoding", "gzip"}
    content_type = {:"Content-Type", "application/json"}
    assert accepts in headers
    assert accepts_encoding in headers
    assert content_encoding in headers
    assert content_type in headers

    assert Keyword.keys(headers) == [
             :"Content-Type",
             :"Content-Encoding",
             :"Accepts-Encoding",
             :Accepts
           ]
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
              badge: 0,
              body: "You got your first message",
              channelId: "Default",
              data: %{},
              expiration: 2419200,
              priority: "default",
              sound: "default",
              title: "Pushed!",
              to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
              ttl: 0
            },
            %PushMessage{
              badge: 0,
              body: "You got your second message",
              channelId: "Default",
              data: %{},
              expiration: 2419200,
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
