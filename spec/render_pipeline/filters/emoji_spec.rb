require 'spec_helper'

describe RenderPipeline::Filter::Emoji do
  subject { described_class }
  let(:context) { RenderPipeline.configuration.render_context_for(:default) }

  it 'processes standard emoji' do
    result = subject.to_html(':smile:', context)
    src = 'http://example.com/images/emoji/unicode/1f604.png'

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <img class="emoji" title=":smile:" alt=":smile:" src="#{src}" height="20" width="20" align="absmiddle">
    HTML
  end

  it 'processes custom emoji' do
    result = subject.to_html(':ello:', context)
    src = 'http://example.com/images/emoji/ello.png'

    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
      <img class="emoji" title=":ello:" alt=":ello:" src="#{src}" height="20" width="20" align="absmiddle">
    HTML
  end

end
