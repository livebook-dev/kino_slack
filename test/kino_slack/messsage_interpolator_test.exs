defmodule KinoSlack.MesssageInterpolatorTest do
  use ExUnit.Case, async: true

  alias KinoSlack.MessageInterpolator, as: Interpolator

  test "it interpolates variables inside a message" do
    first_name = "Hugo"
    last_name = "Baraúna"
    message = "Hi {{first_name}} {{last_name}}! 🎉"

    interpolated_ast = Interpolator.interpolate(message)
    generated_code = Macro.to_string(interpolated_ast)
    {interpolated_message, _} = Code.eval_quoted(interpolated_ast, binding())

    assert generated_code == ~S/"Hi #{first_name} #{last_name}! 🎉"/
    assert interpolated_message == "Hi Hugo Baraúna! 🎉"
  end

  test "it interpolates expressons inside a message" do
    message = "One plus one is: {{1 + 1}}"

    interpolated_ast = Interpolator.interpolate(message)
    generated_code = Macro.to_string(interpolated_ast)
    {interpolated_message, _} = Code.eval_quoted(interpolated_ast, binding())

    assert generated_code == ~S/"One plus one is: #{1 + 1}"/
    assert interpolated_message == "One plus one is: 2"
  end

  test "it interpolates funtion calls inside a message" do
    sum = fn a, b -> a + b end
    message = "1 + 1 is: {{sum.(1, 1)}}"

    interpolated_ast = Interpolator.interpolate(message)
    generated_code = Macro.to_string(interpolated_ast)
    {interpolated_message, _} = Code.eval_quoted(interpolated_ast, binding())

    assert generated_code == ~S/"1 + 1 is: #{sum.(1, 1)}"/
    assert interpolated_message == "1 + 1 is: 2"
  end

  test "it handles messages with only the beginning of interpolation syntax" do
    first_name = "Hugo"
    message = "hi {{ {{first_name}}"

    interpolated_ast = Interpolator.interpolate(message)
    generated_code = Macro.to_string(interpolated_ast)
    {interpolated_message, _} = Code.eval_quoted(interpolated_ast, binding())

    assert generated_code == ~S/"hi {{ #{first_name}"/
    assert interpolated_message == "hi {{ Hugo"
  end
end
