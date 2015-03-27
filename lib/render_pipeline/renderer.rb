require 'active_support/core_ext/string/output_safety'

module RenderPipeline
  class Renderer
    def initialize(content)
      @content = content.presence || ''
    end

    def render(options = {})
      result = pipeline(options[:context] || :default).call(clean_content)[:output].to_s
      if options[:truncate]
        tail = options[:truncate_tail] || '...'
        Truncato.truncate(result, max_length: options[:truncate], tail: tail).html_safe
      else
        result.html_safe
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
  end
end
