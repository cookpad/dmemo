class Keyword < ActiveRecord::Base
  include TextDiff
  include DescriptionLogger

  has_many :logs, -> { order(:id) }, class_name: "KeywordLog"


  validates :name, :description, presence: true
end
