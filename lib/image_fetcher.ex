defmodule ImageFetcher do

  @moduledoc """
  Connect to slack and do things (like fetch images)
  """
  require Logger

  use Inspector
  use Tesla

  plug Tesla.Middleware.FollowRedirects, max_redirects: 3 # defaults to 5

  def fetch_from_slack(image_url, token) do
    Logger.info( fn -> "Fetching image from slack" end)

    headers = %{ "Authorization" => "Bearer #{token}" }
    get(image_url, headers: headers)
    |> process_response
  end

  def fetch(image_url) do
    Logger.info( fn -> "Fetching image from url" end)
    get(image_url)
    |> process_response
  end

  defp process_response(resp) do
    if (resp.status != 200) do
      { :error, resp }
    else
      {:ok, path} = Briefly.create
      path
      |> File.write(resp.body)
      {:ok, path}
    end
  end

end
