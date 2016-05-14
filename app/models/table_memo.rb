class TableMemo < ActiveRecord::Base

  scope :id_or_name, ->(id, name) { where("table_memos.id = ? OR table_memos.name = ?", id.to_i, name) }

  belongs_to :database_memo

  has_many :column_memos, dependent: :destroy

  def source_table_class
    database_memo.data_source.try(:source_table_class, name)
  end

  def source_column_class(column_name)
    source_table_class.try {|table_class| table_class.columns.find {|column_class| column_class.name == column_name } }
  end

  def linked?
    database_memo.linked? && source_table_class.present?
  rescue Mysql2::Error
    false
  end

  def masked?
    MaskedData.masked_table?(database_memo.name, name)
  end
end
