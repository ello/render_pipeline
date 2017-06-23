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
            element['href'] = CGI.unescapeHTML(element['href'])
            prepend_click_service(element)
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

      def prepend_click_service(element)
        begin
          uri = URI.parse(element['href'])
          if uri.scheme == 'http' || uri.scheme == 'https'
            element['href']   = (ENV['CLICK_SERVICE_URL'] || 'https://o.ello.co') + '/' + element['href']
            element['target'] = '_blank'
          end
        rescue URI::Error => e
          logger.error("#{e}")
        end
      end

      def logger
        @logger ||= Logger.new(STDOUT)
      end
    end
  end
end
