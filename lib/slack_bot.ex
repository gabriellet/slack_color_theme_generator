defmodule SlackBot do
  @moduledoc """
  Listen and respond to slack events
  """
  require Logger

  use Application
  use Inspector
  use Slack

  def start(_type, _args) do
    if (slack_token()) do
      Logger.info( fn -> "Starting SlackBot..." end )
      Slack.Bot.start_link(SlackBot, [], slack_token())
    else
      Logger.info( fn -> "No API token.  We won't be starting up the Slack Bot." end )
      {:ok, nil}
    end
  end

  def handle_connect(slack, state) do
    Logger.info( fn -> "Connected to slack as #{slack.me.name}" end )
    {:ok, state}
  end

  def handle_event(message = %{type: "message", file: file}, slack, state) do
    Logger.info( fn -> "Processing slack uploaded file" end)
    file
    |> Map.get(:url_private)
    |> ImageFetcher.fetch_from_slack(slack_token())
    |> process_image
    |> send_theme(message.channel, slack)

    {:ok, state}
  end

  def handle_event(message = %{type: "message", message: %{ attachments: attachments }}, slack, state) do
    Logger.info( fn -> "Processing attachments" end)
    attachments
    |> Enum.map( fn %{:image_url => url} -> url end )
    |> Enum.each( fn img ->
      img
      |> ImageFetcher.fetch
      |> process_image
      |> send_theme(message.channel, slack)
    end )

    {:ok, state}
  end

  # def handle_event(message = %{type: "message"}, slack, state) do
  #   {:ok, state}
  # end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, captain!"

    send_message(text, channel, slack)

    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}

  def send_theme({:ok, theme}, channel, slack) do
    send_message("Theme it up!", channel, slack)
    send_message(theme, channel, slack)
  end

  def send_theme(_resp, _channel, _slack) do; end

  def process_image({ :ok, file_path }) do
    theme = file_path |> SlackColorThemeGenerator.generate

    case theme do
         "" -> { :error, "no theme created" }
         nil -> { :error, "no theme created" }
         _ -> { :ok, theme }
       end
  end

  def process_image({ :error, resp }) do
    IO.puts("fail #{resp.status}")
    { :error, resp.status }
  end


  defp slack_token do
    System.get_env("SLACK_API_TOKEN")
  end

end
