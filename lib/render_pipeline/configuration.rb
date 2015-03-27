require 'singleton'

module RenderPipeline
  class Configuration
    include Singleton

    class << self
      attr_accessor :sanitize_rules
      attr_accessor :render_filters, :render_contexts
      attr_accessor :cache
    end

    self.sanitize_rules = {
      elements: %w(a b i strong em br),
      attributes: { 'a' => [ 'href' ] },
      protocols: { 'a' => { 'href' => [ 'http', 'https', 'mailto' ] } },
      remove_contents: %w(script embed object style),
    }

    self.render_filters = [
      RenderPipeline::Filter::Mentions,
      RenderPipeline::Filter::Rumoji,
      RenderPipeline::Filter::Markdown,
      RenderPipeline::Filter::SyntaxHighlighter,
      RenderPipeline::Filter::Emoji,
      RenderPipeline::Filter::LinkAdjustments,
      RenderPipeline::Filter::ImageAdjustments,
    ]

    self.cache = nil

    def self.add_emoji(emoji)
      Emoji.create(emoji)
    end

    class Context
      SETTINGS = [
        # link adjustments
        :host_name,
        # mentions
        :username_pattern,
        :username_link_cleaner_pattern,
        # emoji
        :asset_root,
        # markdown
        :gfm,
      ]
      attr_accessor(*SETTINGS)

      def initialize
        @host_name = ''
        @asset_root = ''
        @gfm = true
        @username_pattern = /[\w\-]+/
        @username_link_cleaner_pattern = /(>@[\w\-]*?)(_{1,3}[\w\-]+_{1,3}[\w\-]*?<\/a>)/

        default = RenderPipeline.configuration.render_contexts["default"]
        instance_eval(&default[:block]) if default
        yield self if block_given?
      end

      def to_hash
        @hash ||= SETTINGS.each_with_object({}) { |k, o| o[k] = self.send(k) }
      end
    end

    self.render_contexts = { 'default' => { block: proc {} } }
    def self.render_context(name = :default, &block)
      render_contexts[name.to_s] = { block: block, instance: Context.new(&block) }
    end

    def self.render_context_for(name)
      render_contexts[name.to_s][:instance].to_hash
    end
  end

  @@configuration = Configuration

  def self.configuration
    @@configuration
  end

  def self.configuration=(config)
    @@configuration = config
  end

  def self.configure
    yield @@configuration
  end
end
