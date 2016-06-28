class SchemaMemoLog < ActiveRecord::Base
  belongs_to :schema_memo
  belongs_to :user
end
