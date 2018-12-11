module DataSourceAdapters
  module DynamicTable
    class AbstractTable < ApplicationRecord
      self.abstract_class = true
    end
  end
end
