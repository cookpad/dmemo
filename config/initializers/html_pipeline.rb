require 'html/pipeline'

require 'html/pipeline/autolink_filter'
require 'html/pipeline/autolink_keyword_filter'
require 'html/pipeline/inner_text_filter'
require 'html/pipeline/markdown_filter'
require 'html/pipeline/syntax_highlight_filter'

Rails.application.reloader.to_prepare do
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
end
