class Markdown
  attr_reader :md

  def initialize(md)
    @md = md
  end

  def html
    @html ||= Rails.application.config.markdown_to_html_pipeline.call(@md)[:output].html_safe
  end

  def text
    @text ||= Rails.application.config.markdown_to_text_pipeline.call(@md)[:output].html_safe
  end
end
