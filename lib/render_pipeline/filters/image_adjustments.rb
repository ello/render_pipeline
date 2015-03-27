module RenderPipeline
  module Filter
    class ImageAdjustments < HTML::Pipeline::Filter
      def call
        doc.search('img').each do |element|
          unless element['width'] && element['height']
            begin
              width, height = FastImage.size(element['src'])
              element['width'] = width
              element['height'] = height
            rescue FastImage::ImageFetchFailure
              # todo: what to do?
            end
          end
        end
        doc
      end
    end
  end
end
