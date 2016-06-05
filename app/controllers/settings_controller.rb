class SettingsController < ApplicationController
  def show
    @data_sources = DataSource.all
    @masked_data = MaskedDatum.all
  end
end
