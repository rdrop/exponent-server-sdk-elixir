defmodule ExponentServerSdk.PushMessage do
  alias __MODULE__

  @moduledoc """
  Provides a basic payload structure to allow easy communication with the Exponent Push Notification.
  """
  @enforce_keys [:to]
  defstruct to: nil,
            data: nil,
            title: nil,
            body: nil,
            ttl: 0,
            expiration: nil,
            priority: "default",
            sound: "default",
            badge: nil,
            channelId: nil

  @typedoc """
      https://docs.expo.io/versions/v29.0.0/guides/push-notifications#message-format

      Based on the Expo Push Notification Message API JSON

      type PushMessage = {
        /**
         * An Expo push token specifying the recipient of this message.
         */
        to: string,

        /**
         * A JSON object delivered to your app. It may be up to about 4KiB; the total
         * notification payload sent to Apple and Google must be at most 4KiB or else
         * you will get a "Message Too Big" error.
         */
        data?: Object,

        /**
         * The title to display in the notification. Devices often display this in
         * bold above the notification body. Only the title might be displayed on
         * devices with smaller screens like Apple Watch.
         */
        title?: string,

        /**
         * The message to display in the notification
         */
        body?: string,

        /**
         * Time to Live: the number of seconds for which the message may be kept
         * around for redelivery if it hasn't been delivered yet. Defaults to 0.
         *
         * On Android, we make a best effort to deliver messages with zero TTL
         * immediately and do not throttle them
         *
         * This field takes precedence over `expiration` when both are specified.
         */
        ttl?: number,

        /**
         * A timestamp since the UNIX epoch specifying when the message expires. This
         * has the same effect as the `ttl` field and is just an absolute timestamp
         * instead of a relative time.
         */
        expiration?: number,

        /**
         * The delivery priority of the message. Specify "default" or omit this field
         * to use the default priority on each platform, which is "normal" on Android
         * and "high" on iOS.
         *
         * On Android, normal-priority messages won't open network connections on
         * sleeping devices and their delivery may be delayed to conserve the battery.
         * High-priority messages are delivered immediately if possible and may wake
         * sleeping devices to open network connections, consuming energy.
         *
         * On iOS, normal-priority messages are sent at a time that takes into account
         * power considerations for the device, and may be grouped and delivered in
         * bursts. They are throttled and may not be delivered by Apple. High-priority
         * messages are sent immediately. Normal priority corresponds to APNs priority
         * level 5 and high priority to 10.
         */
        priority?: 'default' | 'normal' | 'high',

        // iOS-specific fields

        /**
         * A sound to play when the recipient receives this notification. Specify
         * "default" to play the device's default notification sound, or omit this
         * field to play no sound.
         *
         * Note that on apps that target Android 8.0+ (if using `exp build`, built
         * in June 2018 or later), this setting will have no effect on Android.
         * Instead, use `channelId` and a channel with the desired setting.
         */
        sound?: 'default' | null,

        /**
         * Number to display in the badge on the app icon. Specify zero to clear the
         * badge.
         */
        badge?: number,

        // Android-specific fields

        /**
         * ID of the Notification Channel through which to display this notification
         * on Android devices. If an ID is specified but the corresponding channel
         * does not exist on the device (i.e. has not yet been created by your app),
         * the notification will not be displayed to the user.
         *
         * If left null, a "Default" channel will be used, and Expo will create the
         * channel on the device if it does not yet exist. However, use caution, as
         * the "Default" channel is user-facing and you may not be able to fully
         * delete it.
         */
        channelId?: string
      }
  """
  @type t :: %PushMessage{
          to: String.t(),
          data: map,
          title: String.t(),
          body: String.t(),
          ttl: integer,
          expiration: integer,
          priority: String.t(),
          sound: String.t() | nil,
          badge: integer,
          channelId: String.t() | nil
        }

  @doc """
  Create a PushMessage struct from a single message map.

  ## Examples
      iex> message_map = %{to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]", title: "Pushed!", body: "You got your first message"}
      iex> message = ExponentServerSdk.PushMessage.create(message_map)
      iex> message
      %ExponentServerSdk.PushMessage{badge: nil, body: "You got your first message", channelId: nil, data: nil, expiration: nil, priority: "default", sound: "default", title: "Pushed!", to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]", ttl: 0}
  """
  @spec create(map) :: PushMessage.t()
  def create(message) when is_map(message) do
    struct(PushMessage, message)
  end

  @doc """
  Create a List of PushMessage structs from a list of maps chunked into lists of 100.

  ## Examples
      iex> message_list = [%{to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]", title: "Pushed!", body: "You got your first message"}, %{to: "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]", title: "Pushed Again!", body: "You got your second message"}]
      iex> messages = ExponentServerSdk.PushMessage.create_from_list(message_list)
      iex> messages
      [[%ExponentServerSdk.PushMessage{badge: nil, body: "You got your first message", channelId: nil, data: nil, expiration: nil, priority: "default", sound: "default", title: "Pushed!", to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]", ttl: 0}, %ExponentServerSdk.PushMessage{ badge: nil, body: "You got your second message", channelId: nil, data: nil, expiration: nil, priority: "default", sound: "default", title: "Pushed Again!", to: "ExponentPushToken[YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY]", ttl: 0}]]
  """
  @spec create_from_list(list(map)) :: list(PushMessage.t())
  def create_from_list(messages) when is_list(messages) do
    messages
    |> Enum.map(fn msg -> validate_push_token(struct(PushMessage, msg)) end)
    |> Enum.reject(fn msg -> msg == nil end)
    |> Enum.chunk_every(100)
  end

  # @spec validate_push_token(PushMessage.t()) :: PushMessage.t()
  defp validate_push_token(%PushMessage{to: push_token} = message) when is_map(message) do
    token_list =
      Regex.scan(~r/(?<=^ExponentPushToken\[)(.*)(?=[$\]])/, push_token, capture: :first)

    [raw_token] = List.flatten(token_list)

    if Regex.match?(~r/^ExponentPushToken\[/, push_token) && Regex.match?(~r/\]$/, push_token) &&
         Regex.match?(~r/^[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}$/i, raw_token) do
      message
    else
      nil
    end
  end
end
