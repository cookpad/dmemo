require 'html/pipeline'

Rails.application.config.markdown_to_html_pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::SyntaxHighlightFilter,
  HTML::Pipeline::AutolinkFilter,
  HTML::Pipeline::AutolinkKeywordFilter,
]

Rails.application.config.markdown_to_text_pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::InnerTextFilter,
]
