class TableMemoRawDatasetColumn < ActiveRecord::Base
  belongs_to :table_memo_raw_dataset, class_name: "TableMemoRawDataset"

  def format_value(value)
    datasource_encoding = table_memo_raw_dataset.table_memo.database_memo.data_source.encoding
    datasource_adapter = table_memo_raw_dataset.table_memo.database_memo.data_source.adapter
    if datasource_adapter == 'sqlserver'
      case sql_type
      when 'timestamp'
        '0x' + value.unpack('H*')[0]
      else
        dst_enc = Encoding.default_internal or 'UTF-8'
        value.to_s.encode(dst_enc, datasource_encoding).gsub(/\u0000/, '')
      end
    else
      case sql_type
      when 'timestamp without time zone'
        d, t, z = value.to_s.split
        "#{d} #{t}"
      else
        value.to_s
      end
    end
  end
end
