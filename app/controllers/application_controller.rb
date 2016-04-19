class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :reload_data_sources
  before_action :set_database_memos

  private

  def reload_data_sources
    DataSource.find_each do |data_source|
      DatabaseMemo.import_data_source!(data_source.id)
      data_source.reset_source_table_classes!
    end
  end

  def set_database_memos
    @database_memos = DatabaseMemo.all.includes(:data_source, :table_memos)
  end
end
