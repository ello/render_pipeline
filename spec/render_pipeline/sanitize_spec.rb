require 'spec_helper'

describe RenderPipeline do
  let(:html) do
    <<-HTML.strip_heredoc
    <script>alert("test")</script>
    <style>body{}</style>
    <table>table</table>
    <a href="ftp://cnn.com" onclick="alert("test")">cnn</a>
    <a href="javascropt:alert('test')" onclick="alert("test")">cnn</a>

    <a href="mailto:jejacks0n@gmail.com">je<br>jacks0n</a>
    <a href='http://cnn.com'><i>cnn</i></a>
    <a href="https://cnn.com"><strong>secure</strong> <em>cnn</em></a>
    HTML
  end

  it 'sanitizes the markup' do
    expect(subject.sanitize(html)).to eq <<-HTML.strip_heredoc


    table
    <a>cnn</a>
    <a>cnn</a>

    <a href="mailto:jejacks0n@gmail.com">je<br>jacks0n</a>
    <a href="http://cnn.com"><i>cnn</i></a>
    <a href="https://cnn.com"><strong>secure</strong> <em>cnn</em></a>
    HTML
  end

end
