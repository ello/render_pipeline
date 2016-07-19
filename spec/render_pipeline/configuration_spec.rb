require 'spec_helper'

describe RenderPipeline::Configuration do
  describe 'configuring contexts' do
    it 'configures a default context when no name is provided' do
      RenderPipeline.configure do |config|
        config.render_context do |c|
          c.host_name = 'example.com'
        end
      end
      default_context = RenderPipeline.configuration.render_contexts['default'][:instance]
      expect(default_context.host_name).to eq('example.com')
    end

    it 'configures a named context when a name is provided' do
      RenderPipeline.configure do |c|
        c.render_context :nondefault do
        end
      end
      expect(RenderPipeline.configuration.render_contexts).to have_key('nondefault')
    end

    it 'configures multiple identical named contexts when multiple names are provided' do
      RenderPipeline.configure do |c|
        c.render_context :nondefault, :extranondefault do
        end
      end
      expect(RenderPipeline.configuration.render_contexts).to have_key('nondefault')
      expect(RenderPipeline.configuration.render_contexts).to have_key('extranondefault')
    end
  end
end
