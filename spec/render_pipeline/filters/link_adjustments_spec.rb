require 'spec_helper'

describe RenderPipeline::Filter::LinkAdjustments do
  subject { described_class }
  let(:context) { { host_name: 'ello.co' } }

  it 'makes links relative based on host matching' do
    result = subject.to_html('<a href="https://ello.co/thomashawk/posts/1">Post</a>', context)
    expect(result).to eq('<a href="/thomashawk/posts/1">Post</a>')
  end

  it 'adds nofollow/noopener to external links' do
    result = subject.to_html('<a href="http://www.example.com/test">Test</a>', context)
    a = Nokogiri::XML(result).at_css('a')
    expect(a['rel']).to eq('nofollow noopener')
  end

  it 'sets target for external links' do
    result = subject.to_html('<a href="http://www.example.com/test">Test</a>', context)
    a = Nokogiri::XML(result).at_css('a')
    expect(a['target']).to eq('_blank')
  end

  it 'prepends the click service url on external links' do
    result = subject.to_html('<a href="http://www.example.com/test">Test</a>', context)
    a = Nokogiri::XML(result).at_css('a')
    expect(a['href']).to eq('https://o.ello.co/http://www.example.com/test')
  end

  it 'does not prepend the click service url on external links if protocol is not http/https' do
    result = subject.to_html('<a href="mailto:asdf@ello.co">email</a>', context)
    a = Nokogiri::XML(result).at_css('a')
    expect(a['href']).to eq('mailto:asdf@ello.co')
  end

  it 'does not prepend the click service url if external link is a vimeo link' do
    result = subject.to_html('<a href="https://vimeo.com/215653382">vimeo</a>', context)
    a = Nokogiri::XML(result).at_css('a')
    expect(a['href']).to eq('https://vimeo.com/215653382')
  end
end
