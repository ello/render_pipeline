require 'active_support/core_ext/string/output_safety'
require 'linguist/md5'

module RenderPipeline
  class Renderer
    def initialize(content)
      @content = content.presence || ''
    end

    def render(options = {})
      cache(options) do
        result = pipeline(options[:context] || :default).call(clean_content)[:output].to_s
        if options[:truncate]
          tail = options[:truncate_tail] || '...'
          Truncato.truncate(result, max_length: options[:truncate], tail: tail).html_safe
        else
          result.html_safe
        end
      end
    end

    private

    def pipeline(context)
      @pipeline ||= HTML::Pipeline.new(
        RenderPipeline.configuration.render_filters,
        RenderPipeline.configuration.render_context_for(context)
      )
    end

    def clean_content
      @content.gsub(/\<br\>/, "\r\n").gsub(/\u00a0/, ' ').gsub(/&nbsp;/, ' ')
    end

    def cache(options, &block)
      if cache = RenderPipeline.configuration.cache
        key = Linguist::MD5.hexdigest(options.merge(content: @content.to_s))
        cache.fetch(key, &block)
      else
        yield
      end
    end
  end
end
