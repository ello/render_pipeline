require 'render_pipeline'
require 'rspec'
require 'active_support/core_ext/string/strip'

RSpec.configure do |config|
end

RenderPipeline.configure do |config|

  config.add_emoji 'ello'

  config.render_context :default do |c|
    c.asset_root = "http://example.com/images"
    c.hashtag_root = "http://example.com/search"
  end

  config.render_context :lite do |c|
    c.render_filters = RenderPipeline.configuration.render_filters - [RenderPipeline::Filter::ImageAdjustments]
  end

end
