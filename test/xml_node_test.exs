defmodule XmlNodeTest do
  use ExUnit.Case

  @sample """
  <feed>
    <entry>
      <title>hello</title>
      <content type="html">&lt;p&gt;hello&lt;br&gt;
world&lt;/p&gt;</content>
    </entry>
  </feed>
  """

  test "title" do
    title = XmlNode.from_string(@sample)
    |> XmlNode.first("/feed/entry/title")
    |> XmlNode.text

    assert title == "hello"
  end

  test "content" do
    content = XmlNode.from_string(@sample)
    |> XmlNode.first("/feed/entry/content")
    |> XmlNode.text

    assert content == "<p>hello<br>\nworld</p>"
  end
end
