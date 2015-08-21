require 'spec_helper'

describe RenderPipeline::Filter::Code do
  subject { described_class }
  let(:context) { RenderPipeline.configuration.render_context_for(:default) }

  it 'properly encodes the contents of a code block' do
    result = subject.to_html('<code>puts 1 &amp;amp;&amp;amp; true unless 2 &amp;lt; 1<code>', context)

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <code>puts 1 &amp;&amp; true unless 2 &lt; 1</code>
    HTML
  end

  it 'properly encodes only the contents of a code block' do
    content = <<-CONTENT.strip_heredoc
      &lt;a href="example.com"&gt;check this out!&lt;/a&gt;

      <code>if (1 &amp;amp;&amp;amp; 2 &amp;amp;&amp;amp; (3 &amp;lt; 4)) { alert("hello"); }</code>
    CONTENT

    result = subject.to_html(content)

    expect("#{result}").to eq(<<-HTML.strip_heredoc)
      &lt;a href="example.com"&gt;check this out!&lt;/a&gt;

      <code>if (1 &amp;&amp; 2 &amp;&amp; (3 &lt; 4)) { alert("hello"); }</code>
    HTML
  end

  it 'handles multiple line code blocks with triple ticks' do
    content = <<-CONTENT.strip_heredoc
      <pre><code>ruby
      if (1 &amp;amp;&amp;amp; true)
        puts "hello world!"
      else
        return false unless 3 &amp;lt; 2
      end
      </code></pre>
    CONTENT

    result = subject.to_html(content)
    expect("#{result}").to eq(<<-HTML.strip_heredoc)
      <pre><code>ruby
      if (1 &amp;&amp; true)
        puts \"hello world!\"
      else
        return false unless 3 &lt; 2
      end
      </code></pre>
    HTML
  end
end
