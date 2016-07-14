class DatabaseMemo < ActiveRecord::Base
  include TextDiff
  include DescriptionLogger

  scope :id_or_name, ->(id, name) { where("database_memos.id = ? OR database_memos.name = ?", id.to_i, name) }

  has_many :schema_memos, dependent: :destroy
  has_many :logs, -> { order(:id) }, class_name: "DatabaseMemoLog"

  has_one :data_source, class_name: "DataSource", foreign_key: :name, primary_key: :name

  validates :name, presence: true

  def self.import_data_source!(data_source_id)
    data_source = DataSource.find(data_source_id)
    data_source.reset_data_source_tables!

    db_memo = find_or_create_by!(name: data_source.name)
    schema_memos = db_memo.schema_memos.includes(table_memos: :column_memos).to_a
    schema_memos.each {|memo| memo.linked = false }

    all_table_memos = schema_memos.map(&:table_memos).map(&:to_a).flatten
    all_table_memos.each {|memo| memo.linked = false }

    data_source_tables = data_source.data_source_tables

    data_source_tables.group_by(&:schema_name).each do |schema_name, source_tables|
      schema_memo = schema_memos.find {|memo| memo.name == schema_name } || db_memo.schema_memos.create!(name: schema_name )
      schema_memo.linked = true
      table_memos = all_table_memos.select {|memo| memo.schema_memo_id == schema_memo.id }

      source_tables.each do |source_table|
        table_name = source_table.table_name
        table_memo = table_memos.find {|memo| memo.name == table_name } || schema_memo.table_memos.create!(name: table_name )
        table_memo.linked = true
        column_memos = table_memo.column_memos.to_a

        adapter = source_table.connector.connection.pool.connections.first
        columns = source_table.columns

        column_names = columns.map(&:name)
        column_memos.reject {|memo| column_names.include?(memo.name) }.each {|memo| memo.update!(linked: false) }

        columns.each_with_index do |column, position|
          column_memo = column_memos.find {|memo| memo.name == column.name } || table_memo.column_memos.build(name: column.name)
          column_memo.linked = true
          column_memo.assign_attributes(sql_type: column.sql_type, default: adapter.quote(column.default), nullable: column.null, position: position)
          column_memo.save! if column_memo.changed?
        end
      end
    end
    schema_memos.each {|memo| memo.save! if memo.changed? }
    all_table_memos.each {|memo| memo.save! if memo.changed? }
  rescue Mysql2::Error, PG::Error => e
    raise DataSource::ConnectionBad.new(e)
  end

  def linked?
    data_source.present?
  end

  def single_schema?
    schema_memos.count == 1
  end

  def display_order
    [linked? ? 0 : 1, name]
  end
end
