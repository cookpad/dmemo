class TableMemoRawDatasetColumn < ApplicationRecord
  POSTGRESQL_TYPE_NAME_FOR_TIMESTAMP_WITHOUT_TIME_ZONE = /\Atimestamp(?:\(\d+\))?(?: without time zone)?\z/

  belongs_to :table_memo_raw_dataset, class_name: "TableMemoRawDataset"

  def format_value(value)
    case sql_type
    when POSTGRESQL_TYPE_NAME_FOR_TIMESTAMP_WITHOUT_TIME_ZONE
      d, t, z = value.to_s.split
      "#{d} #{t}"
    else
      value.to_s
    end
  end
end
