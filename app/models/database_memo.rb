class DatabaseMemo < ActiveRecord::Base
  include TextDiff
  include DescriptionLogger

  scope :id_or_name, ->(id, name) { where("database_memos.id = ? OR database_memos.name = ?", id.to_i, name) }

  has_many :table_memos, dependent: :destroy
  has_many :logs, -> { order(:id) }, class_name: "DatabaseMemoLog"

  has_one :data_source, class_name: "DataSource", foreign_key: :name, primary_key: :name

  validates :name, presence: true

  def self.import_data_source!(data_source_id)
    data_source = DataSource.find(data_source_id)
    data_source.reset_source_table_classes!

    db_memo = find_or_create_by!(name: data_source.name)

    data_source.source_table_classes.each do |table_class|
      table_memo = db_memo.table_memos.find_or_create_by!(name: table_class.table_name)
      column_memos = table_memo.column_memos.to_a
      table_class.columns.each do |column|
        adapter = table_class.connection.pool.connections.first
        column_memo = column_memos.find {|memo| memo.name == column.name } || table_memo.column_memos.build(name: column.name)
        column_memo.assign_attributes(sql_type: column.sql_type, default: adapter.quote(column.default), nullable: column.null)
        column_memo.save! if column_memo.changed?
      end
    end
  end

  def linked?
    data_source.present? && data_source.source_base_class.try(:connection) rescue nil
  end
end
