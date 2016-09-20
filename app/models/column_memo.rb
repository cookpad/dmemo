class ColumnMemo < ActiveRecord::Base
  include TextDiff
  include DescriptionLogger

  belongs_to :table_memo

  has_many :logs, -> { order(:id) }, class_name: "ColumnMemoLog"

  validates :name, presence: true

  delegate :schema_memo, to: :table_memo
  delegate :database_memo, to: :schema_memo

  def full_name
    "#{table_memo.database_memo.name}/#{schema_memo.name}.#{table_memo.name}/#{name}"
  end

  def display_order
    [linked? ? 0 : 1, position]
  end
end
