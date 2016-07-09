module HTML
  class Pipeline
    class AutolinkKeywordFilter < Filter
      IGNORED_ANCESTOR_TAGS = %w(pre code a)

      def call
        return doc unless context[:autolink_keywords]

        doc.search('.//text()').each do |node|
          next if has_ancestor?(node, IGNORED_ANCESTOR_TAGS)
          content = node.to_html
          html = content.gsub(patterns) {|matched|
            %{<a href="#{context[:autolink_keywords][matched]}">#{matched}</a>}
          }
          next if html == content
          node.replace(html)
        end
        doc.to_html
      end

      def patterns
        @patterns ||= Regexp.union(context[:autolink_keywords].keys)
      end
    end
  end
end
