module ApplicationHelper
  def link_to_editable(obj, data_options)
    opts = data_options.reverse_merge(pk: obj.id, url: url_for(obj))
    class_value = (%w(editable-field) << data_options[:class]).compact
    content_tag :a, class: class_value, data: opts do
      content_tag :i, "", class: "fa fa-edit"
    end
  end

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
