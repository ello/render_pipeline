module RenderPipeline
  module Filter
    class Rumoji < HTML::Pipeline::TextFilter
      UNICODE_EMOJI_REGEX = /[\u{2194}-\u{1F6FF}]/

      def call
        if UNICODE_EMOJI_REGEX.match(@text)
          ::Rumoji.encode(@text)
        else
          @text
        end
      end
    end
  end
end
