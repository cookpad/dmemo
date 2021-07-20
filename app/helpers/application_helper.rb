module ApplicationHelper
  def render_diff(diff)
    Markdown.new(<<~DIFF).html
      ```diff
      #{diff}
      ```
    DIFF
  end

  def markdown_html(markdown)
    Markdown.new(markdown).html
  end

  def sql_query_format(query)
    rule = AnbtSql::Rule.new
    rule.indent_string = '  '
    rule.space_after_comma = true
    formatter = AnbtSql::Formatter.new(rule)
    formatter.format(query)
  end

  def favicon_override
    if Rails.env.production?
      favicon_link_tag '/favicon.ico'
    else
      favicon_link_tag '/favicon_gray.ico'
    end
  end
end
