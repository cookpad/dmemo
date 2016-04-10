class TopController < ApplicationController
  def show
    @data_sources = DataSource.all
  end
end
