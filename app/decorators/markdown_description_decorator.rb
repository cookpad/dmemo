module MarkdownDescriptionDecorator
  def description_html
    @description_html ||= Rails.application.config.markdown_to_html_pipeline.call(description)[:output].html_safe
  end

  def description_text
    @description_text ||= Rails.application.config.markdown_to_text_pipeline.call(description)[:output].html_safe
  end
end
