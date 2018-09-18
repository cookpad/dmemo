class IgnoredTable < ApplicationRecord
  belongs_to :data_source

  validates :pattern, presence: true
end
