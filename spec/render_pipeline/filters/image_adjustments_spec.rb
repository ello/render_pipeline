require 'spec_helper'

describe RenderPipeline::Filter::ImageAdjustments do
  subject { described_class }
  let(:src) { 'http://lorempixel.com/output/fashion-q-g-96-33-8.jpg' }

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
