class DatabaseMemo < ActiveRecord::Base

  scope :id_or_name, ->(id, name) { where("database_memos.id = ? OR database_memos.name = ?", id.to_i, name) }

  has_many :table_memos, dependent: :destroy
  has_many :database_memo_logs, -> { order(:revision) }

  has_one :data_source, class_name: "DataSource", foreign_key: :name, primary_key: :name

  def self.import_data_source!(data_source_id)
    data_source = DataSource.find(data_source_id)
    data_source.reset_source_table_classes!

    db_memo = find_or_create_by!(name: data_source.name)

    data_source.source_table_classes.each do |table_class|
      table_memo = db_memo.table_memos.find_or_create_by!(name: table_class.table_name)
      table_class.columns.each do |column|
        adapter = table_class.connection.pool.connections.first
        column_memo = table_memo.column_memos.find_or_initialize_by(name: column.name)
        column_memo.assign_attributes(sql_type: column.sql_type, default: adapter.quote(column.default), nullable: column.null)
        column_memo.save! if column_memo.changed?
      end
    end
  end

  def linked?
    data_source.present? && data_source.source_base_class.try(:connection) rescue nil
  end

  def build_database_memo_log
    last_log = database_memo_logs.last
    current_revision = last_log.try(:revision).to_i
    database_memo_logs.build(
      revision: current_revision + 1,
      description: self.description,
      description_diff: Diffy::Diff.new(last_log.try(:description).to_s, self.description).to_s,
    )
  end
end
