require 'render_pipeline'
require 'rspec'
require 'active_support/core_ext/string/strip'
require 'pry'

RSpec.configure do |config|
  config.before(:each) do
    RenderPipeline.configuration.render_contexts = { 'default' => { block: proc {} } }
    RenderPipeline.configure do |render_config|
      render_config.add_emoji 'ello'

      render_config.render_context :default do |c|
        c.asset_root = "http://example.com/images"
        c.hashtag_root = "http://example.com/search"
      end

      render_config.render_context :lite do |c|
        c.render_filters = RenderPipeline.configuration.render_filters - [RenderPipeline::Filter::ImageAdjustments]
      end
    end
  end
end
