module RenderPipeline
  module Filter
    class Mentions < HTML::Pipeline::MentionFilter
      def call
        raise TypeError, 'Mention filter must run before HTML document is set' if @doc.present?
        @doc = Nokogiri::HTML::DocumentFragment.parse("<div>#{html}</div>")
        document_fragment = super
        @doc = nil
        text = document_fragment.inner_html
        response = text[5..text.length - 7]
        response.gsub!(context[:username_link_cleaner_pattern]) { "#{$1}\\#{$2}" }
        response
      end
    end
  end
end
