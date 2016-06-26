class SettingsController < ApplicationController
  def show
    @data_sources = DataSource.all
    @masked_data = MaskedDatum.all
    @ignored_tables = IgnoredTable.all
  end
end
