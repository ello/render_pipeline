require 'spec_helper'

describe RenderPipeline::Filter::LinkAdjustments do
  subject { described_class }
  let(:context) { { host_name: 'ello.co' } }

  it 'makes links relative based on host matching' do
    result = subject.to_html('<a href="https://ello.co/thomashawk/posts/1">Post</a>', context)
    expect(result).to eq('<a href="/thomashawk/posts/1">Post</a>')
  end

  it 'adds a nofollow and sets the target on external links' do
    result = subject.to_html('<a href="http://www.example.com/test">Test</a>', context)
    expect(result).to eq('<a href="https://o.ello.co/http://www.example.com/test" rel="nofollow" target="_blank">Test</a>')
  end

  it 'prepends the click service url on external links' do
    result = subject.to_html('<a href="http://www.example.com/test">Test</a>', context)
    expect(result).to eq('<a href="https://o.ello.co/http://www.example.com/test" rel="nofollow" target="_blank">Test</a>')
  end
end
