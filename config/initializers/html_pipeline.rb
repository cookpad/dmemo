require 'html/pipeline'

Rails.application.config.html_pipeline = HTML::Pipeline.new [
  HTML::Pipeline::MarkdownFilter,
  HTML::Pipeline::RougeFilter,
  HTML::Pipeline::AutolinkFilter
]
