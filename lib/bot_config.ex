defmodule Engine.Viber.BotConfig do
  @moduledoc """
    A module that collects the parameters of bots
  """

  alias Engine.Viber.Conn.ProviderParams

  def get(name, token) do
    config(name, token)
  end

  defp config(name, token) do
    %Agala.BotParams{
      name: name,
      provider: Engine.Viber.Provider,
      handler: Engine.Viber.RequestHandler,
      provider_params: %ProviderParams{
        token: token
      }
    }
  end
end
