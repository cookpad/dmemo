class SynchronizeRawDatasets

  def self.run
    Rails.logger.info "[Start] Synchronized dataset"

    DataSource.all.find_each do |data_source|
      ImportDataSourceRawDatasets.run(data_source.name)
    end
  end

  Rails.logger.info "[Finish] Synchronized dataset"
end
