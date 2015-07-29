module RenderPipeline
  module Filter
    class Hashtag < HTML::Pipeline::Filter
      DEFAULT_IGNORED_ANCESTOR_TAGS = %w(a pre code tt).freeze

      def call
        doc.search('text()').each do |node|
          content = node.to_html
          next unless content.match(context[:hashtag_pattern])
          next if has_ancestor?(node, ignored_ancestor_tags)
          html = hashtag_filter(content)
          next if html == content
          node.replace(html)
        end
        doc
      end

      private

      def hashtag_filter(text)
        text.gsub(context[:hashtag_pattern]) do |match|
          tag = $1[1..-1]
          hashtag_classlist = context[:hashtag_classlist].presence
          root = context[:hashtag_root].presence || '/search'
          "<span data-href='#{root}?terms=%23#{tag}' data-capture='hashtagClick' class=#{hashtag_classlist}>##{tag}</span>"
        end
      end
      # Return ancestor tags to stop the hashtagification
      #
      # @return [Array<String>] Ancestor tags.
      def ignored_ancestor_tags
        if context[:hashtag_ignored_ancestor_tags]
          DEFAULT_IGNORED_ANCESTOR_TAGS || context[:hashtag_ignored_ancestor_tags]
        else
          DEFAULT_IGNORED_ANCESTOR_TAGS
        end
      end
    end
  end
end
