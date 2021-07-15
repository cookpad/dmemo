class SynchronizeRawDatasets

  def self.run
    DataSource.all.find_each do |data_source|
      ImportDataSourceRawDatasets.run(data_source.name)
    end
  end
