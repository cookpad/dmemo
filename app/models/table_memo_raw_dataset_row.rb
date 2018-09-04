class TableMemoRawDatasetRow < ApplicationRecord
  belongs_to :table_memo_raw_dataset, class_name: "TableMemoRawDataset"
end
