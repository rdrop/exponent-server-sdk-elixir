ExponentServerSdk
========
[![Hex.pm](https://img.shields.io/hexpm/v/exponent_server_sdk.svg)](https://hex.pm/packages/exponent_server_sdk)
[![Build Status](https://travis-ci.org/rdrop/exponent-server-sdk-elixir.svg?branch=master)](https://travis-ci.org/rdrop/exponent-server-sdk-elixir)
[![Inline docs](http://inch-ci.org/github/rdrop/exponent-server-sdk-elixir.svg?branch=master)](http://inch-ci.org/github/rdrop/exponent-server-sdk-elixir)

Use to send push notifications to Exponent Experiences from an Elixir/Phoenix server.

## Installation

ExponentServerSdk is currently beta software. You can install it from Hex:

```elixir
def deps do
  [{:exponent_server_sdk, "~> 0.1.0"}]
end
```

Or from Github:

```elixir
def deps do
  [{:exponent_server_sdk, github: "rdrop/exponent-server-sdk-elixir"}]
end
```

and run `mix deps.get`. Now, list the `:exponent_server_sdk` application as your application dependency:

```elixir
def application do
  [applications: [:exponent_server_sdk]]
end
```

## Usage

### Client

The push notification is the preferred way.  This hits the latest version of the api.

####Single Message:

```elixir

# Create a single message map
message = %{
    to: "ExponentPushToken[XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX]",
    title: "Pushed!",
    body: "You got your first message"
  }

# Send it to Expo
{:ok, response} = ExponentServerSdk.Notification.push(message)

# Example Response
{:ok, %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}}
```

#### Multiple Messages:
```elixir

# Create a list of message maps (auto chunks into lists of 100)
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

# Send it to Expo
{:ok, response} = ExponentServerSdk.Notification.push_list(messages)

# Example Response
{:ok,[ %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}, %{"status" => "ok", "id" => "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"} ]}
```

The complete format of the messages can be found [here.](https://docs.expo.io/versions/latest/guides/push-notifications#message-format)

## Contributing

See the [CONTRIBUTING.md](CONTRIBUTING.md) file for contribution guidelines.

## License
ExponentServerSdk is licensed under the MIT license. For more details, see the `LICENSE`
file at the root of the repository. It depends on Elixir, which is under the
Apache 2 license.

[hex]: http://hex.pm
