class IgnoredTable < ActiveRecord::Base
  belongs_to :data_source

  validates :pattern, presence: true
end
