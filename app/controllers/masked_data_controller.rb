class MaskedDataController < ApplicationController
  permits :database_name, :table_name, :column_name

  before_action :require_admin_login, only: %w(new create destroy)

  def index
    redirect_to setting_path
  end

  def show
    redirect_to setting_path
  end

  def new
    @masked_datum = MaskedDatum.new
    @database_name_options = (["*"] + DatabaseMemo.pluck(:name)).map {|x| [x, x]}
  end

  def create(masked_datum)
    @masked_datum = MaskedDatum.create!(masked_datum)
    redirect_to setting_path
  rescue  ActiveRecord::ActiveRecordError => e
    flash[:error] = e.message
    redirect_to new_masked_datum_path
  end

  def destroy(id)
    @masked_datum = MaskedDatum.find(id)
    @masked_datum.destroy!
    redirect_to setting_path
  end
end
