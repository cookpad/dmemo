class TableMemoRawDataset < ActiveRecord::Base
  belongs_to :table_memo

  has_many :columns, class_name: "TableMemoRawDatasetColumn", dependent: :destroy
  has_many :rows, class_name: "TableMemoRawDatasetRow", dependent: :destroy
end
