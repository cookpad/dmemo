require 'html/pipeline'

Rails.application.config.markdown_to_html_pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::RougeFilter,
  HTML::Pipeline::AutolinkFilter,
]

module HTML
  class Pipeline
    class InnerTextFilter < HTML::Pipeline::Filter
      def call
        doc.text
      end
    end
  end
end

Rails.application.config.markdown_to_text_pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::InnerTextFilter,
]
