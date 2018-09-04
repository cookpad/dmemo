class User < ApplicationRecord
  has_many :favorite_tables

  def editable_user?(user_id)
    self.id == user_id.to_i || admin?
  end
end
