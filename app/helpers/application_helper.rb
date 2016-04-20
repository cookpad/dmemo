module ApplicationHelper
  def link_to_editable(obj, data_options)
    opts = data_options.reverse_merge(pk: obj.id, url: url_for(obj))
    class_value = (%w(editable-field) << data_options[:class]).compact
    content_tag :a, class: class_value, data: opts do
      content_tag :i, "", class: "fa fa-edit"
    end
  end

  def shorten_url(*args)
    "#{request.scheme}://#{request.host}:#{request.port}#{shorten_path(*args)}"
  end

  def shorten_path(database_memo, table_memo=nil)
    return shorten_table_path(database_memo.name, table_memo.name) if table_memo
    shorten_database_path(database_memo.name)
  end
end
