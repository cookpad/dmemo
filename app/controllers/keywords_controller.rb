class KeywordsController < ApplicationController
  permits :name, :description

  before_action :redirect_named_path, only: :show

  def index
    @keywords = Keyword.all.order(:name)
  end

  def show(id)
    @keyword = Keyword.find_by!(name: id)
  end

  def new
    @keyword = Keyword.new
  end

  def create(keyword)
    @keyword = Keyword.new(keyword)
    @keyword.build_log(current_user.id)
    @keyword.save!
    redirect_to @keyword
  end

  def edit(id)
    @keyword = Keyword.find(id)
  end

  def update(id, keyword)
    @keyword = Keyword.find(id)
    @keyword.assign_attributes(keyword)
    if @keyword.changed?
      @keyword.build_log(current_user.id)
      @keyword.save!
    end
    redirect_to @keyword
  end

  def destroy(id)
    keyword = Keyword.find(id)
    keyword.destroy!
    redirect_to keywords_path
  end

  private

  def redirect_named_path(id)
    return unless id =~ /\A\d+\z/
    keyword = Keyword.find(id)
    redirect_to keyword_path(keyword.name)
  end
end
