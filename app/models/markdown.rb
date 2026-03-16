class Markdown
  attr_reader :md

  def initialize(md)
    @md = md.to_s
  end

  def html
    @html ||=
      if @md.empty?
        ""
      else
        Rails.application.config.markdown_to_html_pipeline.call(@md, context: html_context)[:output].html_safe
      end
  end

  def html_context
    { autolink_keywords: AutolinkKeyword.links }
  end

  def text
    @text ||=
      if @md.empty?
        ""
      else
        Rails.application.config.markdown_to_text_pipeline.call(@md)[:output].html_safe
      end
  end
end
