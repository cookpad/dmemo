module MarkdownDescriptionDecorator
  def description_html
    @description_html ||= Rails.application.config.html_pipeline.call(description)[:output].html_safe
  end
end
