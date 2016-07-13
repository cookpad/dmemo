class AutolinkKeyword
  def self.links
    @links ||= generate_links
  end

  def self.generate_links
    urls = Rails.application.routes.url_helpers
    links = {}
    DatabaseMemo.includes(schema_memos: :table_memos).each do |database_memo|
      database_memo.schema_memos.each do |schema_memo|
        schema_memo.table_memos.each do |table_memo|
          path = urls.database_schema_table_path(database_memo.name, schema_memo.name, table_memo.name)
          links[table_memo.name] = path
          links["#{schema_memo.name}.#{table_memo.name}"] = path
        end
      end
    end
    Keyword.pluck(:name).each do |keyword|
      links[keyword] = urls.keyword_path(keyword)
    end

    links
  end

  def self.clear_links!
    @links = nil
  end
end
