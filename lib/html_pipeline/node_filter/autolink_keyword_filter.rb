class HTMLPipeline
  class NodeFilter
    class AutolinkKeywordFilter < HTMLPipeline::NodeFilter
      IGNORED_ANCESTOR_TAGS = %w[pre code a].freeze

      def selector
        @selector ||= Selma::Selector.new(match_text_within: "*", ignore_text_within: IGNORED_ANCESTOR_TAGS)
      end

      def handle_text_chunk(text)
        return unless context[:autolink_keywords]

        content = text.to_s
        html = content.gsub(patterns) { |matched|
          %{<a href="#{context[:autolink_keywords][matched]}">#{matched}</a>}
        }
        return if html == content

        text.replace(html, as: :html)
      end

      private

      def patterns
        @patterns ||= Regexp.union(context[:autolink_keywords].keys.sort_by { |k| -k.size })
      end
    end
  end
end
