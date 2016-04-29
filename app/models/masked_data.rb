class MaskedData
  def self.data
    if Rails.env.development?
      YAML.load(File.read("#{Rails.root}/config/masked_data.yml"))[Rails.env]
    else
      @@data ||= YAML.load(File.read("#{Rails.root}/config/masked_data.yml"))[Rails.env]
    end
  end

  def self.masked_database_names
    Array.wrap(data["databases"])
  end

  def self.masked_table_names
    Array.wrap(data["tables"])
  end

  def self.masked_column_names
    Array.wrap(data["columns"])
  end

  def self.masked_database?(database_name)
    masked_database_names.include?(database_name)
  end

  def self.masked_table?(database_name, table_name)
    return true if masked_database?(database_name)
    masked_table_names.any? do |masked_table_name|
      [
        "#{database_name}/#{table_name}",
        table_name
      ].include?(masked_table_name)
    end
  end

  def self.masked_column?(database_name, table_name, column_name)
    return true if masked_database?(database_name)
    return true if masked_table?(database_name, table_name)
    masked_column_names.any? do |masked_column_name|
      [
        "#{database_name}/#{table_name}/#{column_name}",
        "#{table_name}/#{column_name}",
        column_name
      ].include?(masked_column_name)
    end
  end
end
