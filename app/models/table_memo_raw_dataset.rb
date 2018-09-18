class TableMemoRawDataset < ApplicationRecord
  belongs_to :table_memo

  has_many :columns, class_name: "TableMemoRawDatasetColumn", dependent: :destroy
  has_many :rows, class_name: "TableMemoRawDatasetRow", dependent: :destroy

  def same_columns?(source_columns)
    source_columns.all? {|column| columns.where(name: column.name, sql_type: column.sql_type).exists? }
  end
end
