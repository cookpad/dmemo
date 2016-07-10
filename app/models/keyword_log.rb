class KeywordLog < ActiveRecord::Base
  belongs_to :keyword
  belongs_to :user
end
