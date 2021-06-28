class SearchResult
  include ActiveModel::Model
  attr_accessor :keyword, :results

  def initialize(*args)
    super
    self.results = []
  end

  def search!
    return unless keyword.present?
    self.results += TableMemo.where("table_memos.name ILIKE ?", "%#{keyword}%").eager_load(schema_memo: :database_memo).to_a
    self.results += ColumnMemo.where("column_memos.name ILIKE ?", "%#{keyword}%").eager_load(table_memo: {schema_memo: :database_memo}).to_a
  end
end
