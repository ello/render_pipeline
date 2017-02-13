require 'active_support/core_ext/string/output_safety'

module RenderPipeline
  class Renderer
    def initialize(content)
      @content = content.presence || ''
      @render_version_key = RenderPipeline.configuration.render_version_key
    end

    def render(options = {})
      context = RenderPipeline.configuration.render_context_for(options[:context] || :default)
      cache(options) do
        result = pipeline(context).call(clean_content)[:output].to_s.strip
        if options[:truncate]
          tail = options[:truncate_tail] || '...'
          Truncato.truncate(result, max_length: options[:truncate], count_tags: false, tail: tail).html_safe
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
      @content
        .gsub(/\<br\>/, "\r\n")
        .gsub(/\u00a0/, ' ')
        .gsub(/&nbsp;/, ' ')
    end

    def cache(options, &block)
      if cache = RenderPipeline.configuration.cache
        md5hash = hexdigest(options.merge(content: @content.to_s))
        cache.fetch(cache_key(md5hash), &block)
      else
        yield
      end
    end

    def cache_key(md5hash)
      [@render_version_key, md5hash].join()
    end

    # https://github.com/github/linguist/blob/master/lib/linguist/md5.rb#L1
    # Stolen from github-linguist since that is all we appear to be using
    # at this point.
    def hexdigest(obj)
      digest = Digest::MD5.new

      case obj
      when String, Symbol, Integer
        digest.update "#{obj.class}"
        digest.update "#{obj}"
      when TrueClass, FalseClass, NilClass
        digest.update "#{obj.class}"
      when Array
        digest.update "#{obj.class}"
        for e in obj
          digest.update(hexdigest(e))
        end
      when Hash
        digest.update "#{obj.class}"
        for e in obj.map { |(k, v)| hexdigest([k, v]) }.sort
          digest.update(e)
        end
      else
        raise TypeError, "can't convert #{obj.inspect} into String"
      end

      digest.hexdigest
    end
  end
end
