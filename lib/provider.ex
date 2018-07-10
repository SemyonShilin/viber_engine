defmodule Engine.Viber.Provider do
  use Agala.Provider
  @moduledoc """
  Module providing Viber
  """

  def get_receiver do
    Engine.Viber.Receiver
  end

  def get_responser do
    Engine.Viber.Responser
  end

  def init(bot_params, module) do
    {:ok, bot_params}
  end
end
