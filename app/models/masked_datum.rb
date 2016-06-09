class MaskedDatum < ActiveRecord::Base
  validates :database_name, :table_name, :column_name, presence: true

  after_save :update_data!

  def self.data
    @@data ||= update_data!
  end

  def self.masked_database?(database_name)
    data.include?("#{database_name}/*/*")
  end

  def self.masked_table?(database_name, table_name)
    return true if masked_database?(database_name)
    data.include?("#{database_name}/#{table_name}/*")
  end

  def self.masked_column?(database_name, table_name, column_name)
    return true if masked_database?(database_name)
    return true if masked_table?(database_name, table_name)
    data.include?("#{database_name}/#{table_name}/#{column_name}") || data.include?("#{database_name}/*/#{column_name}") || data.include?("*/*/#{column_name}")
  end

  def pack
    "#{database_name}/#{table_name}/#{column_name}"
  end

  private

  def self.update_data!
    @@data = all.map(&:pack)
  end

  def update_data!
    self.class.update_data!
  end
end
