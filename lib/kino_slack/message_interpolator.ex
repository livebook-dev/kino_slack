defmodule KinoSlack.MessageInterpolator do
  @moduledoc false

  def interpolate(message) do
    args = build_interpolation_args(message, "", [])
    args = Enum.reverse(args)
    {:<<>>, [], args}
  end

  defp build_interpolation_args("", buffer, acc) do
    prepend_buffer(buffer, acc)
  end

  defp build_interpolation_args("{{" <> rest, buffer, acc) do
    with [inner, rest] <- String.split(rest, "}}", parts: 2),
         {:ok, expression} <- Code.string_to_quoted(inner) do
      acc = prepend_buffer(buffer, acc)
      acc = prepend_interpolation(expression, acc)
      build_interpolation_args(rest, "", acc)
    else
      _ ->
        build_interpolation_args(rest, <<buffer::binary, "{{">>, acc)
    end
  end

  defp build_interpolation_args(<<char, rest::binary>>, buffer, acc) do
    build_interpolation_args(rest, <<buffer::binary, char>>, acc)
  end

  defp prepend_interpolation(expression, acc) do
    interpolation_node = {
      :"::",
      [],
      [
        {{:., [], [Kernel, :to_string]}, [], [expression]},
        {:binary, [], Elixir}
      ]
    }

    [interpolation_node | acc]
  end

  defp prepend_buffer("", acc), do: acc
  defp prepend_buffer(buffer, acc), do: [buffer | acc]
end
