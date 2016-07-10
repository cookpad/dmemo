class KeywordLogsController < ApplicationController
  def index(keyword_id)
    @keyword = Keyword.find(keyword_id)
    @keyword_logs = @keyword.logs.reorder(id: :desc)
  end
end
