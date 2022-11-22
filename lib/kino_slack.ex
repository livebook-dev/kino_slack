defmodule KinoSlack do
  use Kino.JS, assets_path: "lib/assets"
  use Kino.JS.Live
  use Kino.SmartCell, name: "Slack"

  @impl true
  def init(attrs, ctx) do
    fields = %{
      "token" => attrs["fields"]["token"] || "",
      "channel" => attrs["fields"]["channel"] || "",
      "message" => attrs["fields"]["message"] || ""
    }

    ctx = assign(ctx, fields: fields)
    {:ok, ctx}
  end

  @impl true
  def handle_connect(ctx) do
    {:ok, %{fields: ctx.assigns.fields}, ctx}
  end

  @impl true
  def handle_event("update_token", value, ctx) do
    ctx = update(ctx, :fields, &Map.merge(&1, %{"token" => value}))
    {:noreply, ctx}
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
  def to_attrs(ctx) do
    %{
      "fields" => ctx.assigns.fields
    }
  end

  @impl true
  def to_source(attrs) do
    if any_field_empty?(attrs) do
      ""
    else
      quote do
        req =
          Req.new(
            base_url: "https://slack.com/api",
            auth: {:bearer, unquote(attrs["fields"]["token"])}
          )

        Req.post!(req,
          url: "/chat.postMessage",
          json: %{
            channel: unquote(attrs["fields"]["channel"]),
            text: unquote(attrs["fields"]["message"])
          }
        )
      end
      |> Kino.SmartCell.quoted_to_string()
    end
  end

  def any_field_empty?(attrs) do
    keys = Map.keys(attrs["fields"])
    Enum.any?(keys, fn key -> attrs["fields"][key] in [nil, ""] end)
  end
end
