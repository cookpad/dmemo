class SynchronizeDefinitions

  def self.run
    Rails.logger.info "[Start] Synchronized definition"

    DataSource.all.find_each do |data_source|
      ImportDataSourceDefinitions.run(data_source.name)
    end

    Rails.logger.info "[Finish] Synchronized definition"
  end
end
