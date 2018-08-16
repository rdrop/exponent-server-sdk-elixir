defmodule ExponentServerSdk.ParserTest do
  use ExUnit.Case

  import ExponentServerSdk.Parser

  doctest ExponentServerSdk.Parser

  test ".parse should decode a successful response into a named struct" do
    response = %{
      body:
        "{ \"data\": {\"status\": \"ok\", \"id\": \"XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX\"} }",
      status_code: 200
    }

    expected = %{"status" => "ok", "id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"}
    assert {:ok, expected} == parse(response)
  end

  test ".parse should return an error when response is 400" do
    response = %{body: "{ \"errors\": \"Error message\" }", status_code: 400}
    assert {:error, "Error message", 400} == parse(response)
  end

  test ".parse_list should decode into a list of named structs" do
    json = """
    {"data":
      [
        {"status": "ok", "id": "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"},
        {"status": "ok", "id": "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY"}
      ]
    }
    """

    response = %{body: json, status_code: 200}

    expected = [
      %{"id" => "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX", "status" => "ok"},
      %{"id" => "YYYYYYYY-YYYY-YYYY-YYYY-YYYYYYYYYYYY", "status" => "ok"}
    ]

    assert {:ok, expected} == parse_list(response)
  end
end
