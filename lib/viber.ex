defmodule Engine.Viber do
  @moduledoc """
    The module set webhook for the viber bots and sends custom messages
  """

  alias Agala.{BotParams, Conn}
  alias Agala.Bot.Handler
  alias Engine.Viber.{MessageSender, RequestHandler}

  use GenServer

  @viber_engine Application.get_env(:viber_engine, Engine.Viber)
  @url @viber_engine |> Keyword.get(:url)

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, [name: :"#Engine.Viber::#{opts.name}"])
  end

  def init(opts) do
    set_webhook(opts)
    logger.info("Viber bot #{opts.name} started. Method: webhook")

    {:ok, opts}
  end

  def message_pass(bot_name, hub, message) do
    GenServer.cast(:"#Engine.Viber::#{bot_name}", {:message, hub, message})
  end

  def message_pass(bot_name, message) do
    GenServer.cast(:"#Engine.Viber::#{bot_name}", {:message, message})
  end
  def pre_down(bot_name) do
    GenServer.call(:"#Engine.Viber::#{bot_name}", :delete_webhook)
  end

  def handle_call(:delete_webhook, _from, state) do
    state
    |> delete_webhook()

    {:reply, :ok, state}
  end

  def handle_cast({:message, %{"event" => event} = message}, state) when event == "webhook" do
    logger.info("Webhook for #{state.provider_params.token} was set.")
    {:noreply, state}
  end

  def handle_cast({:message, %{"event" => event, "message_token" => message_token, "user_id" => user_id} = _}, state) when event in ["delivered", "seen"] do
    logger.info("Message #{message_token} was #{event} for #{user_id}")
    {:noreply, state}
  end

  def handle_cast({:message, message}, state) do
    logger.handle(message, state)
    {:noreply, state}
  end

  def handle_cast({:message, _hub, %{"data" => %{"messages" => messages, "chat" => %{"id" => id}}} =  _message}, state) do
    messages
    |> RequestHandler.parse_hub_response()
    |> Enum.filter(& &1)
    |> MessageSender.delivery(id, state)

    {:noreply, state}
  end

  def set_webhook(%BotParams{name: bot_name} = params) do
    conn = %Conn{request_bot_params: params} |> Conn.send_to(bot_name)

    HTTPoison.post(
      webhook_url(conn),
      webhook_upload_body(%{url: server_webhook_url(conn), send_name: true}),
      webhook_header(conn)
    )
    |> parse_body()
    |> resolve_updates(bot_name)
    |> IO.inspect
  end

  def delete_webhook(%BotParams{name: bot_name} = params) do
    conn = %Conn{request_bot_params: params} |> Conn.send_to(bot_name)

    HTTPoison.post(
      webhook_url(conn),
      webhook_upload_body(%{url: ""}),
      webhook_header(conn)
    )
    |> parse_body()
    |> resolve_updates(bot_name)
    |> IO.inspect
  end

  def base_url do
    "https://chatapi.viber.com/pa"
  end

  def webhook_url(_conn) do
    base_url() <> "/set_webhook"
  end

  def logger do
    @viber_engine
    |> Keyword.get(:logger)
  end

  defp webhook_upload_body(body, opts \\ []),
       do:  body |> Poison.encode!

  defp parse_body({:ok, resp = %HTTPoison.Response{body: body}}),
       do: {:ok, %HTTPoison.Response{resp | body: Poison.decode!(body)}}

  defp parse_body(default), do: default

  defp server_webhook_url(conn),
       do: @url <> conn.request_bot_params.provider_params.token

  defp webhook_header(conn) do
    [
      {"X-Viber-Auth-Token", to_string(conn.request_bot_params.provider_params.token)},
      {"Content-Type", "application/json"},
    ]
  end

  defp resolve_updates(
         {
           :ok,
           %HTTPoison.Response{
             status_code: 200,
             body: body
           }
         },
         _bot_params
       ), do: body
end
