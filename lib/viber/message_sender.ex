defmodule Engine.Viber.MessageSender do
  @moduledoc """
  Module for sending messages to telegram
  """

  alias Engine.Viber
  alias Engine.Viber.{Helpers}
  alias Agala.Conn
  alias Agala.BotParams

  def delivery(%Conn{request_bot_params: bot_params, request: %{sender: %{id: id}}} = _conn, messages) do
    IO.inspect "delivery"
    IO.inspect messages

    messages
    |> Enum.each(fn mess ->
      answer(bot_params, id, mess)
    end)
  end

  def delivery(messages, id, %BotParams{} = bot_params) do
    messages
    |> Enum.each(fn message ->
      answer(bot_params, id, message)
    end)
  end

  def answer(%BotParams{name: bot_name} = params, viber_receiver_id, message = %{}) do
    Agala.response_with(
      %Conn{request_bot_params: params}
      |> Conn.send_to(bot_name)
      |> Helpers.send_message(Map.merge(message, %{receiver: viber_receiver_id, type: "rich_media", min_api_version: 2}), [])
      |> IO.inspect
      #      |> Conn.with_fallback(&message_fallback(&1))
    )
  end

  def answer(%BotParams{name: bot_name} = params, viber_receiver_id, message) do
    Agala.response_with(
      %Conn{request_bot_params: params} |> Conn.send_to(bot_name)
      |> Helpers.send_message(viber_receiver_id, message, [])
      |> IO.inspect
      #      |> Conn.with_fallback(&message_fallback(&1))
    )
  end
#
#  def answer(%BotParams{name: bot_name} = params, telegram_user_id, %{text: text} = _message) do
#    Agala.response_with(
#      %Conn{request_bot_params: params} |> Conn.send_to(bot_name)
#      |> Helpers.send_message(telegram_user_id, text, [])
#      |> Conn.with_fallback(&message_fallback(&1))
#    )
#  end
#
#  def answer(%Conn{request_bot_params: %{name: bot_name}, request: %{message: %{from: %{id: user_telegrma_id}}}} = _conn, message) do
#    Agala.response_with(
#      %Conn{} |> Conn.send_to(bot_name)
#      |> Helpers.send_message(user_telegrma_id, message, [])
#      |> Conn.with_fallback(&message_fallback(&1))
#    )
#  end

  defp message_fallback()do

  end
end