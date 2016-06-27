class TableMemo < ActiveRecord::Base
  include TextDiff
  include DescriptionLogger

  scope :id_or_name, ->(id, name) { where("table_memos.id = ? OR table_memos.name = ?", id.to_i, name) }

  belongs_to :database_memo

  has_many :column_memos, dependent: :destroy
  has_many :logs, -> { order(:id) }, class_name: "TableMemoLog"

  has_many :favorite_tables

  validates :name, presence: true

  def source_table_class
    database_memo.data_source.try(:source_table_class, name)
  end

  def source_column_class(column_name)
    source_table_class.try {|table_class| table_class.columns.find {|column_class| column_class.name == column_name } }
  end

  def linked?
    RequestStore["table_memo_linked_#{id}"] ||= database_memo.linked? && source_table_class.present?
  rescue ActiveRecord::ActiveRecordError, Mysql2::Error
    false
  end

  def masked?
    MaskedDatum.masked_table?(database_memo.name, name)
  end

  def favorited_by?(user)
    FavoriteTable.where(user_id: user.id, table_memo_id: id).exists?
  end

  def full_name
    "#{database_memo.name}/#{name}"
  end
end
