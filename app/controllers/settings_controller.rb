class SettingsController < ApplicationController
  def show
    @data_sources = DataSource.all
    @ignored_tables = IgnoredTable.all
  end
end
