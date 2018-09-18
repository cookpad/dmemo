class SchemaMemo < ApplicationRecord
  include TextDiff
  include DescriptionLogger

  belongs_to :database_memo

  has_many :table_memos, dependent: :destroy
  has_many :logs, -> { order(:id) }, class_name: "SchemaMemoLog"

  validates :name, presence: true

  delegate :data_source, to: :database_memo
  delegate :single_schema?, to: :database_memo

  def display_order
    [linked? ? 0 : 1, name]
  end
end
