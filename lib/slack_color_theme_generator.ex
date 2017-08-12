defmodule SlackColorThemeGenerator do
  @moduledoc """
  Generate a Slack color theme (8 hex colors) from an image
  """

  @doc """
  Generates a Slack Color Theme from an image file

  ## Examples

      % ./slack_color_theme_generator my_file.png
      #ffffff,#bavava,...

  """

  use Inspector

  def generate(file) do
    file
    |> generate_theme
  end

  defp generate_theme(file) do
    file
    |> histogram
    |> inspector
    |> Enum.sort_by(fn %{"count" => count} -> count end)
    |> join_hex_colors
  end

  defp join_hex_colors(hist) do
    hist
    |> Enum.map(fn %{"hex" => hex} -> hex end)
    |> Enum.join(",")
  end

  defp histogram(file) do
    Mogrify.open(file)
    |> Mogrify.custom("-background", "white")
    |> Mogrify.custom("-alpha", "remove")
    |> Mogrify.custom("-level", "30%")
    |> Mogrify.custom("-colors", 8)
    |> Mogrify.custom("+dither")
    |> inspector
    |> Mogrify.histogram
  end

end
