class AutolinkKeyword
  def self.links
    urls = Rails.application.routes.url_helpers
    @links ||= DatabaseMemo.includes(schema_memos: :table_memos).each_with_object({}) {|database_memo, h|
      database_memo.schema_memos.each do |schema_memo|
        schema_memo.table_memos.each do |table_memo|
          path = urls.database_schema_table_path(database_memo.name, schema_memo.name, table_memo.name)
          h["#{schema_memo.name}.#{table_memo.name}"] = h[table_memo.name] = path
        end
      end
    }
  end

  def self.clear_links!
    @links = nil
  end
end
