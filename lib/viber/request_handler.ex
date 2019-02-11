defmodule Engine.Viber.RequestHandler do
  @moduledoc false

  use Agala.Chain.Builder
  alias Agala.Conn
  alias Agala.BotParams
  alias Engine.Viber.MessageSender
  alias Engine.Viber
  alias Engine.Viber.Model.{RichMedia, Button}

  chain(Engine.Viber.Chain.Parser)

  chain(:logging_incoming_message_handler)
  chain(:find_bot_handler)
  chain(:send_messege_to_hub_handler)
  chain(:parse_hub_response_handler)
  chain(:delivery_hub_response_handler)

  def logging_incoming_message_handler(%Conn{request: request} = conn, _opts) do
    Viber.logger().info("You have just received message. #{format_request_for_log(request)}")

    conn
  end

  def find_bot_handler(
        %Conn{
          request_bot_params:
            %BotParams{storage: storage, provider_params: %{token: token}} = bot_params,
          request: request
        } = conn,
        _opts
      ) do
    #    conn |> MessageSender.delivery(%{
    #      "receiver" => request.sender.id,
    #      "text" => request.message.text <> "from adapter",
    #      "type" => request.message.type,
    #      "sender" => %{"name" => bot_params.name}
    #    })
    bot = adapter_bot.(token)
    storage.set(bot_params, :bot, bot)

    conn
  end

  def send_messege_to_hub_handler(
        %Conn{
          request_bot_params: %Agala.BotParams{storage: storage} = bot_params,
          request: request
        } = conn,
        _opts
      ) do
    bot = storage.get(bot_params, :bot)

    %{"data" => response} =
      %{data: request}
      |> Map.merge(%{platform: "viber", uid: bot.uid})
      |> call_hub().()

    storage.set(bot_params, :response, response)

    conn
  end

  def parse_hub_response_handler(
        %Conn{request_bot_params: %{storage: storage} = bot_params} = conn,
        _opts
      ) do
    message =
      bot_params
      |> storage.get(:response)
      |> Map.get("messages", [])
      |> parse_hub_response()
      |> Enum.filter(& &1)

    storage.set(bot_params, :messages, message)

    conn
  end

  def delivery_hub_response_handler(
        %Conn{request_bot_params: %{storage: storage} = bot_params} = conn,
        _opts
      ) do
    conn |> MessageSender.delivery(storage.get(bot_params, :messages))

    conn
  end

  def parse_hub_response(messages) do
    parse_hub_response(messages, [])
  end

  defp parse_hub_response([message | tail], formatted_messages) do
    messages =
      Enum.reduce(message, %{}, fn {k, v}, acc ->
        message_mapping().({k, v}, acc)
      end)

    parse_hub_response(tail, [messages | formatted_messages])
  end

  defp parse_hub_response([], updated_messages), do: updated_messages |> Enum.reverse()

  defp format_menu_item(%{"items" => items}), do: format_menu_item(items, [])

  defp format_menu_item([%{"url" => url} = menu_item | tail], state) do
    new_state = [
      Button.make!(%{
        Text: menu_item["name"],
        ActionType: "open-url",
        ActionBody: url,
        Columns: 6,
        Rows: 3
      })
      | state
    ]

    format_menu_item(tail, new_state)
  end

  defp format_menu_item([%{"code" => code} = menu_item | tail], state) do
    new_state = [
      Button.make!(%{
        Text: menu_item["name"],
        ActionType: "reply",
        ActionBody: code,
        Columns: 6,
        Rows: 3
      })
      | state
    ]

    format_menu_item(tail, new_state)
  end

  defp format_menu_item([], state), do: state |> Enum.reverse()

  defp message_mapping do
    fn {k, v}, acc ->
      case k do
        "body" ->
          Map.put(acc, :text, v)

        "menu" ->
          Map.put(acc, :type, "rich_media")
          type_menu(v, acc)

        _ ->
          ""
      end
    end
  end

  defp type_menu(v, acc) do
    with %{"type" => type} <- v do
      case type do
        "inline" ->
          ""
          Map.put(acc, :rich_media, RichMedia.make!(%{Buttons: format_menu_item(v)}))

        "keyboard" ->
          ""

        "auth" ->
          ""

        _ ->
          ""
      end
    end
  end

  defp adapter_bot() do
    with get_bot_fn <- Viber.get_bot_fn(),
         {func, _} <- Code.eval_string(get_bot_fn) do
      func
    end
  end

  def call_hub do
    fn message ->
      Viber.hub_client().call(message)
    end
  end

  defp format_request_for_log(%{sender: %{name: name}, message: %{text: text}}) do
    "#{name} - #{text}"
  end
end
