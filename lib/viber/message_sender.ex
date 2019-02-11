defmodule Engine.Viber.MessageSender do
  @moduledoc """
  Module for sending messages to telegram
  """

  alias Engine.Viber
  alias Engine.Viber.{Helpers}
  alias Agala.Conn
  alias Agala.BotParams

  def delivery(
        %Conn{request_bot_params: bot_params, request: %{sender: %{id: id}}} = _conn,
        messages
      ) do
    messages
    |> Enum.each(fn mess ->
      answer(bot_params, id, %{text: mess.text, type: "text"})
      answer(bot_params, id, Map.delete(mess, :text))
    end)
  end

  def delivery(messages, id, %BotParams{} = bot_params) do
    messages
    |> Enum.each(fn message ->
      answer(bot_params, id, message)
    end)
  end

  def answer(
        %BotParams{name: bot_name} = params,
        viber_receiver_id,
        %{rich_media: _rich_media} = message
      ) do
    Agala.response_with(
      %Conn{request_bot_params: params}
      |> Conn.send_to(bot_name)
      |> Helpers.send_message(
        Map.merge(message, %{receiver: viber_receiver_id, type: "rich_media", min_api_version: 2}),
        []
      )
      |> Conn.with_fallback(&message_fallback(&1))
    )
  end

  def answer(%BotParams{name: bot_name} = params, viber_receiver_id, %{type: "text"} = message) do
    Agala.response_with(
      %Conn{request_bot_params: params}
      |> Conn.send_to(bot_name)
      |> Helpers.send_message(
        Map.merge(message, %{receiver: viber_receiver_id, type: "text", min_api_version: 1}),
        []
      )
      |> Conn.with_fallback(&message_fallback(&1))
    )
  end

  defp message_fallback(args) do
    IO.inspect(args)
  end
end
