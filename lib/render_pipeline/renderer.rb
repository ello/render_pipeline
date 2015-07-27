require 'active_support/core_ext/string/output_safety'
require 'linguist/md5'

module RenderPipeline
  class Renderer
    def initialize(content)
      @content = content.presence || ''
      @render_version_key = RenderPipeline.configuration.render_version_key
    end

    def render(options = {})
      context = RenderPipeline.configuration.render_context_for(options[:context] || :default)
      cache(options) do
        result = pipeline(context).call(clean_content)[:output].to_s
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
      @pipeline ||= HTML::Pipeline.new(context[:render_filters], context)
    end

    def clean_content
      @content.gsub(/\<br\>/, "\r\n").gsub(/\u00a0/, ' ').gsub(/&nbsp;/, ' ')
    end

    def cache(options, &block)
      if cache = RenderPipeline.configuration.cache
        md5hash = Linguist::MD5.hexdigest(options.merge(content: @content.to_s))
        cache.fetch(cache_key(md5hash), &block)
      else
        yield
      end
    end

    def cache_key(md5hash)
      [@render_version_key, md5hash].join()
    end
  end
end
