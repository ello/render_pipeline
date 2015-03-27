require 'spec_helper'

describe RenderPipeline::Filter::Mentions do
  subject { described_class }
  let(:context) { RenderPipeline.configuration.render_context_for(:default) }

  it 'returns a string with links embedded in it for usernames' do
    result = subject.to_html('hey @test!', context)
    expect(result).to eq('hey <a href="/test" class="user-mention">@test</a>!')
  end

  it 'updates usernames surrounded by underscores to work with markdown' do
    result = subject.to_html('yo @_test_', context)
    expect(result).to include '@\_test_'
  end

  it 'updates usernames surrounded by multiple underscores to work with markdown' do
    result = subject.to_html('yo @__test__', context)
    expect(result).to include '@\__test__'
  end

  it 'updates usernames surrounded by an unevent number of underscores to work with markdown' do
    result = subject.to_html('yo @___test______', context)
    expect(result).to include '@\___test______'
  end

  it 'updates usernames surrounded by an uneven number of underscores with more in group two to work with markdown' do
    result = subject.to_html('yo @_te_st______', context)
    expect(result).to include '@\_te_st______'
  end

  it 'updates usernames surrounded by underscores but preceeded by other stuff to work with markdown' do
    result = subject.to_html('yo @-___test______test', context)
    expect(result).to include '@-\___test______test'
  end

  it 'does not modify usernames that only start with underscores' do
    result = subject.to_html('yo @_test', context)
    expect(result).to include '@_test'
  end

  it 'does not modify usernames that only end with underscores' do
    result = subject.to_html('yo @test_', context)
    expect(result).to include '@test_'
  end

  it 'cannot run after the HTML doc attribute has been set in the pipeline' do
    filter = subject.new(Nokogiri::XML::DocumentFragment.parse('<div>foo @test_</div>'))
    expect { filter.call }.to raise_error(TypeError, 'Mention filter must run before HTML document is set')
  end
end
