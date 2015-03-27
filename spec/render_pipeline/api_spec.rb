require 'spec_helper'

describe RenderPipeline do
  describe '.render' do

    it 'should convert @ mentions to links' do
      result = subject.render('<div>@username</div>')
      expect(result).to eq('<div><a href="/username" class="user-mention">@username</a></div>')
    end

    it 'should convert @ mentions to links when the username starts with a dash' do
      result = subject.render('<div>@-username</div>')
      expect(result).to eq('<div><a href="/-username" class="user-mention">@-username</a></div>')
    end

    it 'should convert @ mentions to links when the username starts with an underscore' do
      result = subject.render('<div>@_username</div>')
      expect(result).to eq('<div><a href="/_username" class="user-mention">@_username</a></div>')
    end

    it 'should convert @ mentions to links when the username has a hyphen in it' do
      result = subject.render('<div>@user-name</div>')
      expect(result).to eq('<div><a href="/user-name" class="user-mention">@user-name</a></div>')
    end

    it 'should convert @ mentions to links when the username has an underscore in it' do
      result = subject.render('<div>@user_name</div>')
      expect(result).to eq('<div><a href="/user_name" class="user-mention">@user_name</a></div>')
    end

    it 'converts unicode emoji into their image equivalents' do
      result = subject.render("\xF0\x9F\x98\x81")
      src = "#{subject.configuration.render_context_for(:default)[:asset_root]}/emoji/unicode/1f601.png"

      expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
        <p><img class="emoji" title=":grin:" alt=":grin:" src="#{src}" height="20" width="20" align="absmiddle"></p>
      HTML
    end

  end

  describe '.sanitize' do
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
end
