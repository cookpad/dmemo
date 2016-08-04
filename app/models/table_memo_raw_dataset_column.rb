class TableMemoRawDatasetColumn < ActiveRecord::Base
  belongs_to :table_memo_raw_dataset, class_name: "TableMemoRawDataset"

  def format_value(value)
    case sql_type
    when 'timestamp without time zone'
      d, t, z = value.to_s.split
      "#{d} #{t}"
    else
      value.to_s
    end
  end
end
