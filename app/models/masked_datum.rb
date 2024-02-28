class MaskedDatum < ApplicationRecord
  ANY_NAME = "*".freeze

  validates :database_name, :table_name, :column_name, presence: true

  scope :masking_database, ->(database_name) {
    where(database_name: database_name, table_name: ANY_NAME, column_name: ANY_NAME)
  }
  scope :masking_table, ->(database_name, table_name) {
    masking_database(database_name)
      .or(where(database_name: database_name, table_name: table_name, column_name: ANY_NAME))
      .or(where(database_name: ANY_NAME, table_name: table_name, column_name: ANY_NAME))
  }

  def self.masked_database?(database_name)
    self.masking_database(database_name).exists?
  end

  def self.masked_table?(database_name, table_name)
    self.masking_table(database_name, table_name).exists?
  end

  def self.masked_columns(database_name, table_name)
    return [ANY_NAME] if self.masked_table?(database_name, table_name)

    Set.new(self.where(database_name: database_name, table_name: table_name).pluck(:column_name))
  end

  def pack
    "#{database_name}/#{table_name}/#{column_name}"
  end
end
