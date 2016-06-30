class ColumnMemo < ActiveRecord::Base
  include TextDiff
  include DescriptionLogger

  belongs_to :table_memo

  has_many :logs, -> { order(:id) }, class_name: "ColumnMemoLog"

  validates :name, presence: true

  delegate :schema_memo, to: :table_memo
  delegate :database_memo, to: :schema_memo

  def source_column_class
    table_memo.source_column_class(name)
  end

  def full_name
    "#{table_memo.database_memo.name}/#{table_memo.name}/#{name}"
  end
end
