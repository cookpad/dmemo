require 'html/pipeline'

Rails.application.config.markdown_to_html_pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::RougeFilter,
  HTML::Pipeline::AutolinkFilter,
  HTML::Pipeline::AutolinkKeywordFilter,
  HTML::Pipeline::PopoverKeywordFilter,
]

Rails.application.config.markdown_to_text_pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::InnerTextFilter,
]
