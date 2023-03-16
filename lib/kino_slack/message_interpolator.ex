defmodule KinoSlack.MessageInterpolator do
  @moduledoc false

  def interpolate(message) do
    args = build_interpolation_args(message, [])
    {:<<>>, [], args}
  end

  defp build_interpolation_args("", args) do
    args
  end

  defp build_interpolation_args("{{" <> rest, args) do
    with [inner, rest] <- String.split(rest, "}}", parts: 2),
         {:ok, expression} <- Code.string_to_quoted(inner) do
      args = append_interpolation(args, expression)
      build_interpolation_args(rest, args)
    else
      _ ->
        args = append_string(args, "{{")
        build_interpolation_args(rest, args)
    end
  end

  defp build_interpolation_args(<<char::utf8, rest::binary>>, args) do
    args = append_string(args, <<char::utf8>>)
    build_interpolation_args(rest, args)
  end

  defp append_interpolation(args, expression) do
    interpolation_node = {
      :"::",
      [],
      [
        {{:., [], [Kernel, :to_string]}, [], [expression]},
        {:binary, [], Elixir}
      ]
    }

    args ++ [interpolation_node]
  end

  defp append_string(args, string) do
    last_arg = List.last(args)

    if is_binary(last_arg) do
      last_string = last_arg <> string
      List.replace_at(args, -1, last_string)
    else
      args ++ [string]
    end
  end
end
