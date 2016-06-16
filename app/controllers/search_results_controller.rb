class SearchResultsController < ApplicationController
  permits :keyword

  def show(search_result)
    @search_result = SearchResult.new(search_result)
    @search_result.search!
  end
end
