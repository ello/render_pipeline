require 'spec_helper'

describe RenderPipeline::Configuration do

  it 'allows configuration' do
    old = RenderPipeline.configuration.sanitize_rules
    RenderPipeline.configure { |c| c.sanitize_rules = 'bar' }
    expect(RenderPipeline.configuration.sanitize_rules).to eql('bar')
    RenderPipeline.configuration.sanitize_rules = old
  end

  it 'allows configuring contexts'

end
