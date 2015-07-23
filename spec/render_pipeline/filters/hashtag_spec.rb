require 'spec_helper'

describe RenderPipeline::Filter::Hashtag do
  subject { described_class }
  let(:context) { RenderPipeline.configuration.render_context_for(:default) }

  it 'turns hashtags into links' do
    context[:hashtag_classlist] = "spec-class"
    href = 'http://example.com/search?terms=%23coolstuff'

    result = subject.to_html('Check out #coolstuff', context)

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      Check out <a href="#{href}" class="spec-class">#coolstuff</a>
    HTML
  end

  it 'uses defaults for classlist and root' do
    test_context = context.clone
    test_context[:hashtag_root] = ''
    test_context[:hashtag_classlist] = ''
    href = '/?terms=%23coolstuff'

    result = subject.to_html('Check out #coolstuff', test_context)

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      Check out <a href="#{href}" class="hashtag-link">#coolstuff</a>
    HTML
  end

  it 'does not mangle links with tags' do
    test_link = "[hi there](http://example.com#cool)"

    result = subject.to_html(test_link, context)
    expect(result).to eq test_link
  end 

  it 'does not turn a mid-word-hashtag into a link' do
    result = subject.to_html('Cool#stuff', context)
    expect(result).to eq('Cool#stuff')
  end


end
