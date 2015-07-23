require 'spec_helper'

describe RenderPipeline::Filter::ImageAdjustments do
  subject { described_class }
  # Direct URIs have disappeared, this may be better long term
  let(:src) { 'http://lorempixel.com/96/33/sports/1/' }

  it 'resolves image dimensions for images without both width and height' do
    result = subject.to_html(%{<img src="#{src}"/>})
    expect(result).to eq(%{<img src="#{src}" width="96" height="33">})

    result = subject.to_html(%{<img src="#{src}" height="0"/>})
    expect(result).to eq(%{<img src="#{src}" height="33" width="96">})

    result = subject.to_html(%{<img src="#{src}" width="0"/>})
    expect(result).to eq(%{<img src="#{src}" width="96" height="33">})
  end

  it 'does nothing if there are dimensions already' do
    expect(FastImage).to_not receive(:size)

    result = subject.to_html(%{<img src="#{src}" width="0" height="0"/>})
    expect(result).to eq(%{<img src="#{src}" width="0" height="0">})
  end

end
