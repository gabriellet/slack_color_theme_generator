defmodule SlackColorThemeGenerator.CLI do
  require Logger
  def main(args) do
    Logger.info( fn -> "Running CLI" end )
    args
    |> Enum.map(&SlackColorThemeGenerator.generate/1)
    |> IO.puts
  end
end
