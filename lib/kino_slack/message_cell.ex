defmodule KinoSlack.MessageCell do
  @moduledoc false

  use Kino.JS, assets_path: "lib/assets"
  use Kino.JS.Live
  use Kino.SmartCell, name: "Slack message"

  @impl true
  def init(attrs, ctx) do
    fields = %{
      "token_secret_name" => attrs["token_secret_name"] || "",
      "channel" => attrs["channel"] || "",
      "message" => attrs["message"] || ""
    }

    ctx = assign(ctx, fields: fields)
    {:ok, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{fields: ctx.assigns.fields}, ctx}
  end

  @impl true
  def handle_event("update_channel", value, ctx) do
    ctx = update(ctx, :fields, &Map.merge(&1, %{"channel" => value}))
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_message", value, ctx) do
    ctx = update(ctx, :fields, &Map.merge(&1, %{"message" => value}))
    {:noreply, ctx}
  end

  @impl true
  def handle_event("update_token_secret_name", value, ctx) do
    broadcast_event(ctx, "update_token_secret_name", value)
    ctx = update(ctx, :fields, &Map.merge(&1, %{"token_secret_name" => value}))
    {:noreply, ctx}
  end

  @impl true
  def to_attrs(ctx) do
    ctx.assigns.fields
  end

  @impl true
  def to_source(attrs) do
    required_fields = ~w(token_secret_name channel message)
    message_ast = KinoSlack.MessageInterpolator.interpolate(attrs["message"])

    if all_fields_filled?(attrs, required_fields) do
      quote do
        req =
          Req.new(
            base_url: "https://slack.com/api",
            auth: {:bearer, System.fetch_env!(unquote("LB_#{attrs["token_secret_name"]}"))}
          )

        response =
          Req.post!(req,
            url: "/chat.postMessage",
            json: %{
              channel: unquote(attrs["channel"]),
              text: unquote(message_ast)
            }
          )

        case response.body do
          %{"ok" => true} -> :ok
          %{"ok" => false, "error" => error} -> {:error, error}
        end
      end
      |> Kino.SmartCell.quoted_to_string()
    else
      ""
    end
  end

  defp all_fields_filled?(attrs, keys) do
    Enum.all?(keys, fn key -> attrs[key] not in [nil, ""] end)
  end
end
