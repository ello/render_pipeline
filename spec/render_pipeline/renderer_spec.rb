require 'spec_helper'

describe RenderPipeline::Renderer, vcr: true do
  subject { described_class }
  let(:click_service_url) { 'https://o.ello.co' }
  let(:content) do
    <<-CONTENT.strip_heredoc
    hey everybody<br/>this is\u00a0 some<br>test&nbsp;content.
    <img src="http://lorempixel.com/96/33/sports/1/">
    CONTENT
  end

  let(:broken_links) { '[here is code](http://example.com?one=two&three=4)' }
  let(:broken_code) do
    <<-CONTENT.strip_heredoc
    ```ruby
    if 2 > 1
      do_something.each |do|
        what_else_breaks && who_knows?
      end
    end
    ```
    CONTENT
  end
  let(:encoded_links) { '[here is code](http://example.com?one=two&amp;three=4)' }
  let(:encoded_code) do
    <<-CONTENT.strip_heredoc
    ```ruby
    if 2 &gt; 1
      do_something.each |do|
        what_else_breaks &amp;&amp; who_knows?
      end
    end
    ```
    CONTENT
  end

  let(:xss_content) do
    <<-CONTENT.strip_heredoc
    ```
      &lt;script&gt;alert('good example!');&lt;/script&gt;
    ```
    &lt;script&gt;alert('what happened');&lt;/script&gt;
    CONTENT
  end

  let(:xss_markdown) do
    <<-CONTENT.strip_heredoc
      [Click me](javascript:alert("Hello!"))
    CONTENT
  end

  let(:emoji) do
    <<-CONTENT.strip_heredoc
      :business_suit_levitating:
    CONTENT
  end

  let(:emoji_in_code) do
    <<-CONTENT.strip_heredoc
      `:business_suit_levitating:`
    CONTENT
  end

  let(:strikethrough) do
    <<-CONTENT.strip_heredoc
      ~~@ello~~
    CONTENT
  end

  let(:mention) do
    <<-CONTENT.strip_heredoc
      @ello_some_user
    CONTENT
  end

  let(:hashtag) do
    <<-CONTENT.strip_heredoc
      #hashtag_with_underscores
    CONTENT
  end

  let(:table) do
    <<-CONTENT.strip_heredoc
      |#|Count|Category|
      | ---:| ---:|:--- |
      |1|7311|Dogs|
      |2|47573|Arts|
    CONTENT
  end

  it 'should only single encode ampersands in URLs' do
    rendered_links = subject.new(broken_links).render
    expect("#{rendered_links}\n").to eq(<<-HTML.strip_heredoc)
    <p><a href="#{click_service_url}/http://example.com?one=two&amp;three=4" rel="nofollow noopener" target="_blank">here is code</a></p>
    HTML
  end

  it 'should also ignore already encoded ampersands and not replace them' do
    rendered_links = subject.new(encoded_links).render
    expect("#{rendered_links}\n").to eq(<<-HTML.strip_heredoc)
    <p><a href="#{click_service_url}/http://example.com?one=two&amp;three=4" rel="nofollow noopener" target="_blank">here is code</a></p>
    HTML
  end

  it 'should not destroy code by double escaping &s' do
    rendered_code = subject.new(broken_code).render
    expect("#{rendered_code}\n").to eq(<<-HTML.strip_heredoc)
      <pre><code class="ruby">if 2 &gt; 1
        do_something.each |do|
          what_else_breaks &amp;&amp; who_knows?
        end
      end
      </code></pre>
    HTML
  end

  it 'should also ignore already encoded code' do
    rendered_code = subject.new(encoded_code).render
    expect("#{rendered_code}\n").to eq(<<-HTML.strip_heredoc)
      <pre><code class="ruby">if 2 &gt; 1
        do_something.each |do|
          what_else_breaks &amp;&amp; who_knows?
        end
      end
      </code></pre>
    HTML
  end

  it 'properly encodes script tags' do
    result = subject.new(xss_content).render

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <pre><code>  &lt;script&gt;alert('good example!');&lt;/script&gt;
      </code></pre>

      <p>&lt;script&gt;alert('what happened');&lt;/script&gt;</p>
    HTML
  end

  it 'properly removes unsafe markdown links' do
    result = subject.new(xss_markdown).render

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <p>[Click me](javascript:alert("Hello!"))</p>
    HTML
  end

  it 'properly encodes emoji shortcuts' do
    result = subject.new(emoji).render

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <p><img class="emoji" title=":business_suit_levitating:" alt=":business_suit_levitating:" src="http://example.com/images/emoji/unicode/1f574.png" height="20" width="20" align="absmiddle"></p>
    HTML
  end

  it 'should not encode emoji within code blocks' do
    rendered_code = subject.new(emoji_in_code).render
    expect("#{rendered_code}\n").to eq(<<-HTML.strip_heredoc)
      <p><code>:business_suit_levitating:</code></p>
    HTML
  end

  it 'properly encodes strikethroughs containing mentions' do
    result = subject.new(strikethrough).render

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <p><del><a href="/ello" class="user-mention">@ello</a></del></p>
    HTML
  end

  it 'properly encodes mentions' do
    result = subject.new(mention).render

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <p><a href="/ello_some_user" class="user-mention">@ello_some_user</a></p>
    HTML
  end

  it 'properly encodes hashtags' do
    result = subject.new(hashtag).render

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <p><a href="https://o.ello.co/http://example.com/search?terms=%23hashtag_with_underscores" data-href="http://example.com/search?terms=%23hashtag_with_underscores" data-capture="hashtagClick" class="hashtag-link" rel="nofollow noopener" target="_blank">#hashtag_with_underscores</a></p>
    HTML
  end

  let(:hashtag_with_diacritics) do
    <<-CONTENT.strip_heredoc
      #Göteborg
    CONTENT
  end

  it 'properly encodes hashtags containing diacritics' do
    result = subject.new(hashtag_with_diacritics).render

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <p><a href="https://o.ello.co/http://example.com/search?terms=%23G%C3%B6teborg" data-href="http://example.com/search?terms=%23Göteborg" data-capture="hashtagClick" class="hashtag-link" rel="nofollow noopener" target="_blank">#Göteborg</a></p>
    HTML
  end

  it 'properly encodes tables' do
    result = subject.new(table).render

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
       <table>
       <thead>
       <tr>
       <th style="text-align: right">#</th>
       <th style="text-align: right">Count</th>
       <th style="text-align: left">Category</th>
       </tr>
       </thead>
       <tbody>
       <tr>
       <td style="text-align: right">1</td>
       <td style="text-align: right">7311</td>
       <td style="text-align: left">Dogs</td>
       </tr>
       <tr>
       <td style="text-align: right">2</td>
       <td style="text-align: right">47573</td>
       <td style="text-align: left">Arts</td>
       </tr>
       </tbody>
       </table>
    HTML
  end

  it 'can render content' do
    result = subject.new(content).render
    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
    <p>hey everybody<br>this is  some<br>
    test content.<br>
    <img src="http://lorempixel.com/96/33/sports/1/" width="96" height="33"></p>
    HTML
  end

  it 'can render content with different contexts' do
    result = subject.new(content).render(context: :lite)
    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
    <p>hey everybody<br>this is  some<br>
    test content.<br>
    <img src="http://lorempixel.com/96/33/sports/1/"></p>
    HTML
  end

  it 'can truncate the response' do
    result = subject.new(content).render(truncate: 13, truncate_tail: '<<<')
    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
    <p>hey everybody&lt;&lt;&lt;</p>
    HTML
  end

  it 'passes the correct things to the html pipeline' do
    call_stub = double(call: { output: '_output_' })
    hash = { render_filters: '_render_filters_', opt1: '_render_context_' }
    expect(RenderPipeline.configuration).to receive(:render_context_for).with(:default).and_return(hash)
    expect(HTML::Pipeline).to receive(:new).with('_render_filters_', hash).and_return(call_stub)
    expect(subject.new(content).render).to eq('_output_')
  end
end
