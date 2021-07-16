class SynchronizeDefinitions

  def self.run
    DataSource.all.find_each do |data_source|
      ImportDataSourceDefinitions.run(data_source.name)
    end
  end
end