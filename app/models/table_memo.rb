class TableMemo < ActiveRecord::Base
  include TextDiff

  scope :id_or_name, ->(id, name) { where("table_memos.id = ? OR table_memos.name = ?", id.to_i, name) }

  belongs_to :database_memo

  has_many :column_memos, dependent: :destroy
  has_many :table_memo_logs, -> { order(:id) }

  def source_table_class
    database_memo.data_source.try(:source_table_class, name)
  end

  def source_column_class(column_name)
    source_table_class.try {|table_class| table_class.columns.find {|column_class| column_class.name == column_name } }
  end

  def linked?
    database_memo.linked? && source_table_class.present?
  rescue ActiveRecord::ActiveRecordError, Mysql2::Error
    false
  end

  def masked?
    MaskedData.masked_table?(database_memo.name, name)
  end

  def build_log(user_id)
    last_log = table_memo_logs.last
    current_revision = last_log.try(:revision).to_i
    table_memo_logs.build(
      revision: current_revision + 1,
      user_id: user_id,
      description: self.description,
      description_diff: diff(last_log.try(:description), self.description),
    )
  end
end
