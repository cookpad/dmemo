class SynchronizeDataSources
  def self.run
    DataSource.all.find_each do |data_source|
      DatabaseMemo.import_data_source!(data_source.id)
    end
  end
end
