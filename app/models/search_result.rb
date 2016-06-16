class SearchResult
  include ActiveModel::Model
  attr_accessor :keyword, :results

  SEARCH_LIMIT = 5

  def initialize(*args)
    super
    self.results = []
  end

  def search!
    return unless keyword.present?
    self.results += DatabaseMemo.where("name LIKE ?", "%#{keyword}%").limit(SEARCH_LIMIT).to_a
    self.results += TableMemo.where("name LIKE ?", "%#{keyword}%").limit(SEARCH_LIMIT).to_a
    self.results += ColumnMemo.where("name LIKE ?", "%#{keyword}%").limit(SEARCH_LIMIT).to_a
  end
end
