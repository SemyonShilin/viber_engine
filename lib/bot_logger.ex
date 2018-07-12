defmodule Engine.Viber.BotLogger do
  @moduledoc false
  require Logger

  @viber_engine Application.get_env(:viber_engine, Engine.Viber)

  def debug(message) do
    @viber_engine
    |> Keyword.get(:logger)
    |> debug(message)
  end

  def info(message) do
    @viber_engine
    |> Keyword.get(:logger)
    |> info(message)
  end

  defp debug(:console, message) do
    Logger.debug fn -> "----> #{message} <----" end
  end

  defp info(:console, message) do
    Logger.info fn -> "----> #{message} <----" end
  end

  defp debug(:file, message) do
  end

  defp info(:file, message) do
  end
end
