module RenderPipeline
  module Filter
    # See this issue: https://github.com/github/linguist/issues/1984
    # and this comment re: html-pipeline use of linguist:
    # https://github.com/github/linguist/issues/1984#issuecomment-69497419
    # They recommend going with pygments here instead if I read that correctly.
    class SyntaxHighlighter < HTML::Pipeline::Filter
      def call
        doc.search('pre').each do |node|
          default = context[:highlight] && context[:highlight].to_s
          next unless lang = node['lang'] || default
          next unless lexer = lexer_for(lang)
          text = node.inner_text

          html = highlight_with_timeout_handling(lexer, text)
          next if html.nil?

          if (node = node.replace(html).first)
            klass = node["class"]
            klass = [klass, "highlight-#{lang}"].compact.join " "

            node["class"] = klass
          end
        end
        doc
      end

      def highlight_with_timeout_handling(lexer, text)
        lexer.highlight(text)
      rescue Timeout::Error => boom
        nil
      end

      def lexer_for(lang)
        Pygments::Lexer[lang]
      end
    end
  end
end
