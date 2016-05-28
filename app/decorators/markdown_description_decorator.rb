module MarkdownDescriptionDecorator
  def description_markdown
    @description_markdown ||= Markdown.new(description)
  end

  def description_html
    @description_html ||= description_markdown.html.html_safe
  end

  def description_text
    @description_text ||= description_markdown.text.html_safe
  end
end
