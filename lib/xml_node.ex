defmodule XmlNode do
  require Record
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")
  
  def from_file(path, options \\ [quiet: true]) do
    File.read!(path) |> from_string(options)
  end

  def from_string(xml_string, options \\ [quiet: true]) do
    {doc, []} = xml_string
                |> :binary.bin_to_list
                |> :xmerl_scan.string(options)

    doc
  end

  def first(node), do: node |> take_one
  def first(node, path), do: node |> xpath(path) |> take_one
  defp take_one([head | _]), do: head
  defp take_one(_), do: nil

  def text(node), do: node |> xpath("./text()") |> extract_text("")
  defp extract_text([xmlText(value: value) | rest], result) do
    extract_text(rest, result <> List.to_string(value))
  end
  defp extract_text(_, result), do: result

  def xpath(nil, _), do: []
  def xpath(node, path) do
    :xmerl_xpath.string(to_char_list(path), node)
  end
end
