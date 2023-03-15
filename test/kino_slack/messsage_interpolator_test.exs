defmodule KinoSlack.MesssageInterpolatorTest do
  use ExUnit.Case, async: true

  alias KinoSlack.MessageInterpolator, as: Interpolator

  test "it interpolates variables inside a message" do
    first_name = "Hugo"
    last_name = "Baraúna"
    message = "Hi {{first_name}} {{last_name}}! 🎉"

    interpolated_ast = Interpolator.interpolate(message)
    {interpolated_message, _} = Code.eval_quoted(interpolated_ast, binding())

    assert interpolated_message == "Hi Hugo Baraúna! 🎉"
  end

  test "it interpolates expressons inside a message" do
    message = "One plus one is: {{1 + 1}}"

    interpolated_ast = Interpolator.interpolate(message)
    {interpolated_message, _} = Code.eval_quoted(interpolated_ast, binding())

    assert interpolated_message == "One plus one is: 2"
  end

  test "it interpolates expressions with functinos and vars inside a message" do
    first_name = "Hugo"
    message = "Do you {{first_name}}, know {{1 + 1}} ?"

    interpolated_ast = Interpolator.interpolate(message)
    {interpolated_message, _} = Code.eval_quoted(interpolated_ast, binding())

    assert interpolated_message == "Do you Hugo, know 2 ?"
  end

  test "it handles messags with only the beginning of interpolation syntax" do
    first_name = "Hugo"
    message = "hi {{ {{first_name}}"

    interpolated_ast = Interpolator.interpolate(message)
    {interpolated_message, _} = Code.eval_quoted(interpolated_ast, binding())

    assert interpolated_message == "hi {{ Hugo"
  end
end
