module RenderPipeline
  module Filter
    class LinkAdjustments < HTML::Pipeline::Filter
      def call
        host_regex = %r{\Ahttp(s)?://(www.)?#{context[:host_name]}(/.*)}
        doc.search('a').each do |element|
          element['href'] ||= ''

          if context[:use_absolute_url]
            href = determine_href(element)
            element['href'] = CGI.unescapeHTML(href)
          end

          # make relative links.
          # todo: move this regexp into configuration
          unless context[:use_absolute_url]
            if element['href'] =~ host_regex
              element['href'] = CGI.unescapeHTML($3)
            end
          end

          # adjust links that are not relative.
          if element['href'][0] != '/'
            element['rel'] = 'nofollow noopener'
            element['target'] = '_blank'
            element['href'] = CGI.unescapeHTML(element['href'])
            element['href'] = (ENV['CLICK_SERVICE_URL'] || 'https://o.ello.co') + '/' + element['href']
          end
        end
        doc
      end

      private

      def determine_href(element)
        if element['href'].starts_with?('/')
          "https://#{context[:host_name]}" + element['href']
        else
          element['href']
        end
      end
    end
  end
end
