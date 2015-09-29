defmodule Vim.Version do
  @release   "https://github.com/vim/vim/releases.atom"
  @patch_key "vim_patch"

  def latest do
    case HTTPoison.get(@release) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        entry = body
        |> XmlNode.from_string
        |> XmlNode.first("/feed/entry")

        [patch | _] = entry
        |> XmlNode.first("title")
        |> XmlNode.text
        |> String.split(~r/:/)

        content = entry
        |> XmlNode.first("content")
        |> XmlNode.text
        |> String.replace(~r/<.+?>/, "")

        {:ok, patch, content}
      {:ok, %HTTPoison.Response{status_code: status}} ->
        {:error, "unpexected status: #{status}"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "error", reason}
    end
  end

  def check_latest do
    case latest do
      {:ok, patch, content} ->
        brain_patch = Brain.get(@patch_key, "")
        if brain_patch != patch do
          Brain.set(@patch_key, patch)
          """
          [#{brain_patch}] -> [#{patch}]
          ```
          #{content}
          ```
          """
          |> String.strip
          |> Bot.incoming("dev", "vim", Env.get("Slack_vim_icon"))
        end
      {:error, _, _} -> nil
    end
  end

  def check_now do
    text = case latest do
      {:ok, patch, content} ->
        """
        ```
        Brain : [#{Brain.get(@patch_key, "")}]
        Latest: [#{patch}]
        ---
        #{content}
        ```
        """
      {:error, _, _} ->
        "Oops"
    end

    Bot.incoming(text, "dev", "vim", Env.get("Slack_vim_icon"))
    nil
  end
end
