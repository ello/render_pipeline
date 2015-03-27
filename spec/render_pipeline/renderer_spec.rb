require 'spec_helper'

describe RenderPipeline::Renderer do
  subject { described_class }
  let(:content) do
    <<-CONTENT.strip_heredoc
    hey everybody<br/>this is\u00a0 some<br>test&nbsp;content.
    CONTENT
  end

  it 'can render content' do
    result = subject.new(content).render
    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
    <p>hey everybody<br>this is  some<br>
    test content.</p>
    HTML
  end

  it 'can truncate the response' do
    result = subject.new(content).render(truncate: 20, truncate_tail: '<<<')
    expect("#{result}\n").to eq(<<-HTML.strip_heredoc)
    <p>hey everybody<br/><<<</p>
    HTML
  end

  it 'passes the correct things to the html pipeline' do
    call_stub = double(call: { output: '_output_' })
    expect(RenderPipeline.configuration).to receive(:render_filters).and_return('_render_filters_')
    expect(RenderPipeline.configuration).to receive(:render_context_for).with(:default).and_return('_render_context_')
    expect(HTML::Pipeline).to receive(:new).with('_render_filters_', '_render_context_').and_return(call_stub)
    expect(subject.new(content).render).to eq('_output_')
  end

  it 'caches the results if there is a cache to use (assumes Rails.cache)' do
    cache_stub = double(fetch: '_cached_output_')
    expect(RenderPipeline.configuration).to receive(:cache).and_return(cache_stub)
    expect(cache_stub).to receive(:fetch).with('de22474bb0b6d2215d83f7942b028465').and_return('_cached_output_')
    expect(subject.new(content).render).to eq('_cached_output_')
  end

  it 'caches the results based on options' do
    cache_stub = double(fetch: '_cached_output_')
    expect(RenderPipeline.configuration).to receive(:cache).and_return(cache_stub)
    expect(cache_stub).to receive(:fetch).with('ab12217661ecf6d7ffd7ff76a3243e70').and_return('_cached_output_')
    expect(subject.new(content).render(foo: 'bar')).to eq('_cached_output_')
  end

end
