defmodule KinoSlack.MessageInterpolator do
  @moduledoc false

  def interpolate(message) do
    args = build_interpolation_args(message, [""])
    args = Enum.reverse(args)
    {:<<>>, [], args}
  end

  defp build_interpolation_args("", args) do
    args
  end

  defp build_interpolation_args("{{" <> rest, args) do
    with [inner, rest] <- String.split(rest, "}}", parts: 2),
         {:ok, expression} <- Code.string_to_quoted(inner) do
      args = add_interpolation(args, expression)
      build_interpolation_args(rest, args)
    else
      _ ->
        args = add_string(args, "{{")
        build_interpolation_args(rest, args)
    end
  end

  defp build_interpolation_args(<<char::utf8, rest::binary>>, args) do
    args = add_string(args, <<char::utf8>>)
    build_interpolation_args(rest, args)
  end

  defp add_interpolation(args, expression) do
    interpolation_node = {
      :"::",
      [],
      [
        {{:., [], [Kernel, :to_string]}, [], [expression]},
        {:binary, [], Elixir}
      ]
    }

    [interpolation_node | args]
  end

  defp add_string(args, string) do
    [head | tail] = args

    if is_binary(head) do
      [head <> string | tail]
    else
      [string | args]
    end
  end
end
