require 'spec_helper'

describe RenderPipeline::Filter::SyntaxHighlighter do
  subject { described_class }
  let(:context) { RenderPipeline.configuration.render_context_for(:default) }

  context 'using Pygments to highlight code' do
    let(:encoded_code) do
    <<-CONTENT.strip_heredoc
    <pre lang='ruby'><code>
    if 2 &gt; 1
      do_something.each |do|
        what_else_breaks &amp;&amp; who_knows?
      end
    end
    </code></pre>
    CONTENT
    end

    it 'should annotate with classes based on language' do
      result = subject.to_html(encoded_code, context)

      expect("#{result}").to eq(<<-HTML.strip_heredoc)
      <div class="highlight highlight-ruby"><pre><span class="k">if</span> <span class="mi">2</span> <span class="o">&gt;</span> <span class="mi">1</span>
        <span class="n">do_something</span><span class="o">.</span><span class="n">each</span> <span class="o">|</span><span class="k">do</span><span class="o">|</span>
          <span class="n">what_else_breaks</span> <span class="o">&amp;&amp;</span> <span class="n">who_knows?</span>
        <span class="k">end</span>
      <span class="k">end</span>
      </pre></div>
    HTML
    end
  end
end
