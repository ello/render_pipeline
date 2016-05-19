module RenderPipeline
  module Filter
    class LinkAdjustments < HTML::Pipeline::Filter
      def call
        host_regex = %r{\Ahttp(s)?://(www.)?#{context[:host_name]}(/.*)}
          doc.search('a').each do |element|
          element['href'] ||= ''

          if context[:notification_email]
            href = "https://#{context[:host_name]}" + element['href']
            element['href'] = CGI.unescapeHTML(href)
          end

          # make relative links.
          # todo: move this regexp into configuration
          unless context[:notification_email]
            if element['href'] =~ host_regex
              element['href'] = CGI.unescapeHTML($3)
            end
          end

          # adjust links that are not relative.
          if element['href'][0] != '/'
            element['rel'] = 'nofollow'
            element['target'] = '_blank'
            element['href'] = CGI.unescapeHTML(element['href'])
          end
        end
        doc
      end
    end
  end
end
