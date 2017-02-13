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

  it 'should only single encode ampersands in URLs' do
    rendered_links = subject.new(broken_links).render
    expect("#{rendered_links}\n").to eq(<<-HTML.strip_heredoc)
    <p><a href="#{click_service_url}/http://example.com?one=two&amp;three=4" rel="nofollow" target="_blank">here is code</a></p>
    HTML
  end

  it 'should also ignore already encoded ampersands and not replace them' do
    rendered_links = subject.new(encoded_links).render
    expect("#{rendered_links}\n").to eq(<<-HTML.strip_heredoc)
    <p><a href="#{click_service_url}/http://example.com?one=two&amp;three=4" rel="nofollow" target="_blank">here is code</a></p>
    HTML
  end

  it 'should not destroy code by double escaping &s' do
    rendered_code = subject.new(broken_code).render
    expect("#{rendered_code}\n").to eq(<<-HTML.strip_heredoc)
    <div class="highlight highlight-ruby"><pre><span class="k">if</span> <span class="mi">2</span> <span class="o">&gt;</span> <span class="mi">1</span>
      <span class="n">do_something</span><span class="o">.</span><span class="n">each</span> <span class="o">|</span><span class="k">do</span><span class="o">|</span>
        <span class="n">what_else_breaks</span> <span class="o">&amp;&amp;</span> <span class="n">who_knows?</span>
      <span class="k">end</span>
    <span class="k">end</span>
    </pre></div>
    HTML
  end

  it 'should also ignore already encoded code' do
    rendered_code = subject.new(encoded_code).render
    expect("#{rendered_code}\n").to eq(<<-HTML.strip_heredoc)
    <div class="highlight highlight-ruby"><pre><span class="k">if</span> <span class="mi">2</span> <span class="o">&gt;</span> <span class="mi">1</span>
      <span class="n">do_something</span><span class="o">.</span><span class="n">each</span> <span class="o">|</span><span class="k">do</span><span class="o">|</span>
        <span class="n">what_else_breaks</span> <span class="o">&amp;&amp;</span> <span class="n">who_knows?</span>
      <span class="k">end</span>
    <span class="k">end</span>
    </pre></div>
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

  it 'caches the results if there is a cache to use (assumes Rails.cache)' do
    cache_stub = double(fetch: '_cached_output_')
    expect(RenderPipeline.configuration).to receive(:cache).and_return(cache_stub)
    expect(cache_stub).to receive(:fetch).with('d0ca634e714f3602976a270a80968943').and_return('_cached_output_')
    expect(subject.new(content).render).to eq('_cached_output_')
  end

  it 'caches the results based on options' do
    cache_stub = double(fetch: '_cached_output_')
    expect(RenderPipeline.configuration).to receive(:cache).and_return(cache_stub)
    expect(cache_stub).to receive(:fetch).with('94a838e8df0191dc8995965aa1ea5172').and_return('_cached_output_')
    expect(subject.new(content).render(foo: 'bar')).to eq('_cached_output_')
  end

end
