defmodule KinoSlackTest do
  use ExUnit.Case

  import Kino.Test

  setup :configure_livebook_bridge

  describe "code generation" do
    test "returns correct code when all fields are filled" do
      attrs = %{
        "fields" => %{
          "token_secret_name" => "SLACK_TOKEN",
          "channel" => "slack-channel",
          "message" => "text message"
        }
      }

      {_kino, source} = start_smart_cell!(KinoSlack, attrs)

      expected_source = ~S"""
      req =
        Req.new(
          base_url: "https://slack.com/api",
          auth: {:bearer, System.fetch_env!("LB_SLACK_TOKEN")}
        )

      response =
        Req.post!(req,
          url: "/chat.postMessage",
          json: %{channel: "slack-channel", text: "text message"}
        )

      case response.body do
        %{"ok" => true} -> "Message successfully sent"
        %{"ok" => false, "error" => error} -> "An error happened: #{error}"
      end
      """

      expected_source = String.trim(expected_source)

      assert source == expected_source
    end

    test "returns empty source code when any of the fields is empty" do
      attrs = %{
        "fields" => %{
          "token_secret_name" => "SLACK_TOKEN",
          "channel" => "slack-channel",
          "message" => "text message"
        }
      }

      attrs = put_in(attrs["fields"]["token_secret_name"], "")
      assert KinoSlack.to_source(attrs) == ""
    end
  end
end
