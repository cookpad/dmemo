class SchemaMemoLog < ApplicationRecord
  belongs_to :schema_memo
  belongs_to :user
end
