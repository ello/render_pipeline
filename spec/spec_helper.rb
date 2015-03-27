require 'render_pipeline'
require 'rspec'
require 'active_support/core_ext/string/strip'

RSpec.configure do |config|
end

RenderPipeline.configure do |config|

  config.add_emoji 'ello'

  config.render_context do |c|
    c.asset_root = "http://example.com/images"
  end

end
