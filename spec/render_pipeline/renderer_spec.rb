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

  describe 'rendering content' do
    let(:result) { subject.new(content).render }

    describe 'given ampersands in URLs' do
      let(:content) do
        '[here is code](http://example.com?one=two&three=4)'
      end

      it 'should only single-encode them' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
        <p><a href="#{click_service_url}/http://example.com?one=two&amp;three=4" rel="nofollow" target="_blank">here is code</a></p>
        HTML
      end
    end

    describe 'given already-encoded ampersands in URLs' do
      let(:content) { '[here is code](http://example.com?one=two&amp;three=4)' }

      it 'should ignore and not replace them' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
        <p><a href="#{click_service_url}/http://example.com?one=two&amp;three=4" rel="nofollow" target="_blank">here is code</a></p>
        HTML
      end
    end


    describe 'given code that includes ampersands' do
      let(:content) do
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

      it 'should not destroy code by double escaping &s' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <pre><code>if 2 &gt; 1
            do_something.each |do|
              what_else_breaks &amp;&amp; who_knows?
            end
          end
          </code></pre>
        HTML
      end
    end

    describe 'given code that includes escaped ampersands' do
      let(:content) do
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

      it 'should still ignore already-encoded code' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <pre><code>if 2 &gt; 1
            do_something.each |do|
              what_else_breaks &amp;&amp; who_knows?
            end
          end
          </code></pre>
        HTML
      end
    end

    describe 'given code with escaped script tags in it that poses an XSS threat' do
      let(:content) do
        <<-CONTENT.strip_heredoc
        ```
          &lt;script&gt;alert('good example!');&lt;/script&gt;
        ```
        &lt;script&gt;alert('what happened');&lt;/script&gt;
        CONTENT
      end

      it 'properly encodes/strips the script tags' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <pre><code>  &lt;script&gt;alert('good example!');&lt;/script&gt;
          </code></pre>

          <p>&lt;script&gt;alert('what happened');&lt;/script&gt;</p>
        HTML
      end
    end

    describe 'given code with unescaped script tags in it that poses an XSS threat' do
      let(:content) do
        <<-CONTENT.strip_heredoc
        ```
          <script>alert('good example!');</script>
        ```
        <script>alert('what happened');</script>
        CONTENT
      end

      it 'properly encodes/strips the script tags' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <pre><code>  &lt;script&gt;alert('good example!');&lt;/script&gt;
          </code></pre>
        HTML
      end
    end

    describe 'given markdown with unsafe links' do
      let(:content) do
        <<-CONTENT.strip_heredoc
          [Click me](javascript:alert("Hello!"))
        CONTENT
      end

      it 'properly removes the unsafe links' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <p>[Click me](javascript:alert("Hello!"))</p>
        HTML
      end
    end

    describe 'given emoji shortcuts' do
      let(:content) do
        <<-CONTENT.strip_heredoc
          :business_suit_levitating:
        CONTENT
      end

      it 'properly encodes the emoji shortcuts' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <p><img class="emoji" title=":business_suit_levitating:" alt=":business_suit_levitating:" src="http://example.com/images/emoji/unicode/1f574.png" height="20" width="20" align="absmiddle"></p>
        HTML
      end
    end

    describe 'given emoji shortcuts inside code blocks' do
      let(:content) do
        <<-CONTENT.strip_heredoc
          `:business_suit_levitating:`
        CONTENT
      end

      it 'should not encode emoji within code blocks' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <p><code>:business_suit_levitating:</code></p>
        HTML
      end
    end

    describe 'given text with strikethroughs' do
      let(:content) do
        <<-CONTENT.strip_heredoc
          ~~@ello~~
        CONTENT
      end

      it 'properly encodes strikethroughs containing mentions' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <p><del><a href="/ello" class="user-mention">@ello</a></del></p>
        HTML
      end
    end

    describe 'given text with mentions' do
      let(:content) do
        <<-CONTENT.strip_heredoc
          @ello_some_user
        CONTENT
      end

      it 'properly encodes mentions' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <p><a href="/ello_some_user" class="user-mention">@ello_some_user</a></p>
        HTML
      end
    end

    describe 'given text with mentions and underscores' do
      let(:content) do
        <<-CONTENT.strip_heredoc
          @_ello_some_user
        CONTENT
      end

      it 'properly encodes mentions with underscores' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <p><a href="/_ello_some_user" class="user-mention">@_ello_some_user</a></p>
        HTML
      end
    end

    describe 'given text with hashtags' do
      let(:content) do
        <<-CONTENT.strip_heredoc
          #hashtag_with_underscores
        CONTENT
      end

      it 'properly encodes hashtags' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <p><a href="https://o.ello.co/http://example.com/search?terms=%23hashtag_with_underscores" data-href="http://example.com/search?terms=%23hashtag_with_underscores" data-capture="hashtagClick" class="hashtag-link" rel="nofollow" target="_blank">#hashtag_with_underscores</a></p>
        HTML
      end
    end

    describe 'given text with blockquotes' do
      let(:content) do
        <<-CONTENT.strip_heredoc
          > blockquoted content
        CONTENT
      end

      it 'properly encodes blockquotes' do
        expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
          <blockquote>
          <p>blockquoted content</p>
          </blockquote>
        HTML
      end
    end
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
