require 'spec_helper'

describe RenderPipeline::Filter::Rumoji do
  subject { described_class }

  it 'converts unicode emoji to textual representations' do
    result = subject.to_html("\xF0\x9F\x98\x81")
    expect(result).to eq(':grin:')
  end

  it 'does not call into Rumoji if there are no unicode emoji' do
    expect(Rumoji).not_to receive(:encode)

    result = subject.to_html('hello!')
    expect(result).to eq('hello!')
  end

  it 'does not screw up existing emoji representations' do
    result = subject.to_html(":smile: \xF0\x9F\x98\x81")
    expect(result).to eq(":smile: :grin:")
  end

  it 'handles the full range of emoji' do
    result = subject.to_html("\xE2\x8C\x9A -|- \xF0\x9F\x99\x8F") # U+231A / U+1F64F
    expect(result).to eq(':watch: -|- :pray:')
  end

end
