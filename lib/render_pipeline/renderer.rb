require 'active_support/core_ext/string/output_safety'

module RenderPipeline
  class Renderer
    def initialize(content)
      @content = content.presence || ''
      @render_version_key = RenderPipeline.configuration.render_version_key
    end

    def render(context: :default)
      context = RenderPipeline.configuration.render_context_for(context)
      result = pipeline(context).call(clean_content)[:output].to_s
      if context[:truncate_length] && context[:truncate_tail]
        Truncato.truncate(result,
                          max_length: context[:truncate_length],
                          count_tags: false,
                          tail: context[:truncate_tail]).html_safe
      else
        result.html_safe
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
  end
end
