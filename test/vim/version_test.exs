defmodule Vim.VersionTest do
  use ExUnit.Case
  import Mock

  @test_response {:ok, %HTTPoison.Response{status_code: 200, body: """
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom" xmlns:media="http://search.yahoo.com/mrss/" xml:lang="en-US">
  <entry>
    <id>tag:github.com,2008:Repository/40997482/v7.4.873</id>
    <updated>2015-09-17T21:20:42Z</updated>
    <link rel="alternate" type="text/html" href="/vim/vim/releases/tag/v7.4.873"/>
    <title>v7.4.873: patch 7.4.873</title>
    <content type="html">&lt;p&gt;Problem:    Compiler warning for unused variable. (Tony Mechelynck)&lt;br&gt;
Solution:   Remove the variable.  Also fix int vs long_u mixup.&lt;/p&gt;</content>
  </entry>
</feed>
"""}}

  test_with_mock "latest",
  HTTPoison, [:passthrough], [get: fn _ -> @test_response end] do
    {res, patch, content} = Vim.Version.latest

    assert res == :ok
    assert patch == "v7.4.873"
    assert content == "Problem:    Compiler warning for unused variable. (Tony Mechelynck)\nSolution:   Remove the variable.  Also fix int vs long_u mixup."
  end

end
