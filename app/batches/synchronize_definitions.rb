class SynchronizeDefinitions

  def self.run
    Rails.logger.info "[Start] Synchronized definition"

    DataSource.all.find_each do |data_source|
      if data_source.deprecated_adapter?
        Rails.logger.warn "[Skip] #{data_source.name} uses deprecated #{data_source.adapter} adapter"
        next
      end

      ImportDataSourceDefinitions.run(data_source.name)
    end

    Rails.logger.info "[Finish] Synchronized definition"
  end
end
