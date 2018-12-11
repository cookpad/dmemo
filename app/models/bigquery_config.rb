class BigqueryConfig < ApplicationRecord
  validates :project_id, :dataset, presence: true
  validates :data_source, uniqueness: true

  belongs_to :data_source
end
