class MaskedDatum < ActiveRecord::Base
  after_save :update_data!

  def self.data
    @@data ||= update_data!
  end

  def self.masked_database?(database_name)
    data[:database].include?(database_name)
  end

  def self.masked_table?(database_name, table_name)
    return true if masked_database?(database_name)
    data[:table].any? do |masked_table_name|
      [
        "#{database_name}/#{table_name}",
        table_name
      ].include?(masked_table_name)
    end
  end

  def self.masked_column?(database_name, table_name, column_name)
    return true if masked_database?(database_name)
    return true if masked_table?(database_name, table_name)
    data[:column].any? do |masked_column_name|
      [
        "#{database_name}/#{table_name}/#{column_name}",
        "#{table_name}/#{column_name}",
        column_name
      ].include?(masked_column_name)
    end
  end

  private

  def self.update_data!
    data = { database: [], table: [], column: [] }
    all.find_each do |datum|
      case [datum.database_name?, datum.table_name?, datum.column_name?]
        when [false, false, true]
          data[:column] << datum.column_name
        when [false, true, true]
          data[:column] << "#{datum.table_name}/#{datum.column_name}"
        when [true, true, true]
          data[:column] << "#{datum.database_name}/#{datum.table_name}/#{datum.column_name}"
        when [false, true, false]
          data[:table] << datum.table_name
        when [true, true, false]
          data[:table] << "#{datum.database_name}/#{datum.table_name}"
        when [true, false, false]
          data[:database] << datum.database_name
      end
    end
    @@data = data
  end

  def update_data!
    self.class.update_data!
  end
end
