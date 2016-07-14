module HTML
  class Pipeline
    class PopoverKeywordFilter < Filter
      def call
        return doc unless context[:autolink_keywords]

        doc.search('//a').each do |node|
          content = node.to_html
          binding.pry
          # html = content.gsub(patterns) {|matched|
          #   %{<a href="#{context[:autolink_keywords][matched]}">#{matched}</a>}
          # }
          # next if html == content
          # node.replace(html)
          # node
        end
        doc.to_html
      end

      def patterns
        @patterns ||= Regexp.union(context[:autolink_keywords].keys.sort_by {|k| -k.size })
      end
    end
  end
end
