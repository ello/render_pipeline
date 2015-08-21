module RenderPipeline
  module Filter
    class Code < HTML::Pipeline::Filter
      def call
        # Previous steps in the rendering pipeline escape HTML
        # such as & (&amp;), > (&gt;), < (&lt;). Unescape
        # them in code blocks so that when rendered, code appears
        # correctly.
        doc.search('code').each do |element|
          element.content = CGI.unescapeHTML(element.content)
        end

        doc
      end
    end
  end
end
