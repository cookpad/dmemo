class Keyword
  def self.links
    urls = Rails.application.routes.url_helpers
    @links ||= TableMemo.joins(:schema_memo).pluck(:id, :name, 'schema_memos.name').each_with_object({}) {|(id, name, schema_name), h|
      h[name] = urls.keyword_path(name)
      h["#{schema_name}.#{name}"] = urls.table_memo_path(id)
    }
  end

  def self.clear_links!
    @links = nil
  end
end
