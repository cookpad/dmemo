class DatabaseMemo < ActiveRecord::Base
  def self.import_data_source!(data_source_id)
    data_source = DataSource.find(data_source_id)
    transaction do
      create!(
        name: data_source.dbname
      )
    end
  end
end
