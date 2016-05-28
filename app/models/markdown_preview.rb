class MarkdownPreview
  attr_reader :markdown

  delegate :html, to: :markdown

  def initialize(md)
    @markdown = Markdown.new(md)
  end
end
