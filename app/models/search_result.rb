class SearchResult
  include ActiveModel::Model
  attr_accessor :keyword, :tables, :columns

  def search!(table_page:, column_page:, per_page:)
    return unless keyword.present?
    pattern = "%#{keyword}%"
    self.tables  = TableMemo.where("table_memos.name LIKE ? OR table_memos.description LIKE ?", pattern, pattern)
                            .eager_load(schema_memo: :database_memo)
                            .order(description: :desc, updated_at: :desc)
                            .page(table_page).per(per_page)
    self.columns = ColumnMemo.where("column_memos.name LIKE ? OR column_memos.description LIKE ?", pattern, pattern)
                            .eager_load(table_memo: {schema_memo: :database_memo})
                            .order(description: :desc, updated_at: :desc)
                            .page(column_page).per(per_page)
  end
end
