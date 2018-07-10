defmodule Engine.Viber.Spec do
  @moduledoc """
    Speck for a telegram to run engine in the supervisor
  """

  def engine_spec(bot_name, token) do
    [
      {Engine.Viber, Engine.Viber.BotConfig.get(bot_name, token)},
      {Agala.Bot, Engine.Viber.BotConfig.get(bot_name, token)}
    ]
  end
end
