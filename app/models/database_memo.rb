class DatabaseMemo < ApplicationRecord
  include TextDiff
  include DescriptionLogger

  scope :id_or_name, ->(id, name) { where("database_memos.id = ? OR database_memos.name = ?", id.to_i, name) }

  has_many :schema_memos, dependent: :destroy
  has_many :logs, -> { order(:id) }, class_name: "DatabaseMemoLog"

  has_one :data_source, class_name: "DataSource", foreign_key: :name, primary_key: :name

  validates :name, presence: true

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
