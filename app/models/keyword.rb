class Keyword < ActiveRecord::Base
  include TextDiff
  include DescriptionLogger

  has_many :logs, -> { order(:id) }, class_name: "KeywordLog"

  validates :name, :description, presence: true

  after_save :clear_keyword_links
  after_destroy :clear_keyword_links

  private

  def clear_keyword_links
    AutolinkKeyword.clear_links! if name_changed? || destroyed?
  end
end
