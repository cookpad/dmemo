require 'html_pipeline'
require 'html_pipeline/convert_filter/markdown_filter'
require 'html_pipeline/node_filter/syntax_highlight_filter'

require_relative '../../lib/html_pipeline/node_filter/autolink_keyword_filter'

Rails.application.reloader.to_prepare do
  Rails.application.config.markdown_to_html_pipeline = HTMLPipeline.new(
    convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
    node_filters: [
      HTMLPipeline::NodeFilter::SyntaxHighlightFilter.new,
      HTMLPipeline::NodeFilter::AutolinkKeywordFilter.new,
    ],
  )

  Rails.application.config.markdown_to_text_pipeline = HTMLPipeline.new(
    convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
    sanitization_config: { elements: [] },
  )
end
