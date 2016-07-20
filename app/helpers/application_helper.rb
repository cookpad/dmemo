module ApplicationHelper
  def render_diff(diff)
    Markdown.new(<<-DIFF).html
```diff
#{diff}
```
    DIFF
  end

  def markdown_html(markdown)
    Markdown.new(markdown).html
  end
end
