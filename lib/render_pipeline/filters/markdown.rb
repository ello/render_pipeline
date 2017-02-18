module RenderPipeline
  module Filter
    class Markdown < HTML::Pipeline::Filter

      def call
        parser.render(html)
      end

      private

      def parser
        Redcarpet::Markdown.new(renderer,
                                fenced_code_blocks: true,
                                autolink: true,
                                strikethrough: true,
                                no_intra_emphasis: true)
      end

      def renderer
        Redcarpet::Render::HTML.new(safe_links_only: true,
                                    hard_wrap: true)
      end
    end
  end
end
