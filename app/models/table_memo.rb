class TableMemo < ActiveRecord::Base
  include TextDiff
  include DescriptionLogger

  scope :id_or_name, ->(id, name) { where("table_memos.id = ? OR table_memos.name = ?", id.to_i, name) }

  belongs_to :schema_memo

  has_one :raw_dataset, class_name: "TableMemoRawDataset", dependent: :destroy

  has_many :column_memos, dependent: :destroy
  has_many :logs, -> { order(:id) }, class_name: "TableMemoLog", dependent: :destroy

  has_many :favorite_tables, dependent: :destroy

  validates :name, presence: true

  delegate :database_memo, to: :schema_memo
  delegate :data_source, to: :schema_memo

  after_save :clear_keyword_links
  after_destroy :clear_keyword_links

  def masked?
    MaskedDatum.masked_table?(database_memo.name, name)
  end

  def favorited_by?(user)
    FavoriteTable.where(user_id: user.id, table_memo_id: id).exists?
  end

  def full_name
    "#{database_memo.name}/#{name}"
  end

  def display_order
    [linked? ? 0 : 1, name]
  end

  private

  def clear_keyword_links
    AutolinkKeyword.clear_links! if name_changed? || destroyed?
  end
end
