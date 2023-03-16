defmodule KinoSlack.MessageInterpolator do
  @moduledoc false

  def interpolate(message) do
    ast = quote do: <<"">>
    interpolate(message, ast)
  end

  defp interpolate("", result_ast) do
    result_ast
  end

  defp interpolate("{{" <> rest, ast) do
    with [inner, rest] <- String.split(rest, "}}", parts: 2),
         {:ok, expression} <- Code.string_to_quoted(inner) do
      ast = append_interpolation(ast, expression)
      interpolate(rest, ast)
    else
      _ ->
        ast = append_string(ast, "{{")
        interpolate(rest, ast)
    end
  end

  defp interpolate(<<char::utf8, rest::binary>>, ast) do
    new_ast = append_string(ast, <<char::utf8>>)
    interpolate(rest, new_ast)
  end

  defp append_interpolation(ast, expression) do
    interpolation_node = {
      :"::",
      [],
      [
        {{:., [], [Kernel, :to_string]}, [], [expression]},
        {:binary, [], Elixir}
      ]
    }

    {_, _, args} = ast
    args = args ++ [interpolation_node]

    {:<<>>, [], args}
  end

  defp append_string(ast, string) do
    {_, _, args} = ast
    last_arg = List.last(args)

    new_args =
      if is_binary(last_arg) do
        last_string = last_arg <> string
        List.replace_at(args, -1, last_string)
      else
        args ++ [string]
      end

    {:<<>>, [], new_args}
  end
end
