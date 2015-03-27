module RenderPipeline
  module Filter
    class LinkAdjustments < HTML::Pipeline::Filter
      def call
        host_regex = %r{\Ahttp(s)?://(www.)?#{context[:host_name]}(/.*)}
        doc.search('a').each do |element|
          element['href'] ||= ''

          # make relative links.
          # todo: move this regexp into configuration
          if element['href'] =~ host_regex
            element['href'] = $3
          end

          # adjust links that are not relative.
          if element['href'][0] != '/'
            element['rel'] = 'nofollow'
            element['target'] = '_blank'
          end
        end
        doc
      end
    end
  end
end
