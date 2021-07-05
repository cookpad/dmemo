class SearchResultsController < ApplicationController
  permits :keyword

  def show(search_result)
    @search_result = SearchResult.new(search_result)
    @search_result.search!(table_page: params[:table_page], column_page: params[:column_page], per_page: 30)
  end
end
