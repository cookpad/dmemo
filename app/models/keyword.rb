class Keyword
  def self.links
    @links ||= TableMemo.distinct(:name).pluck(:name).each_with_object({}) {|name, h|
      h[name] = Rails.application.routes.url_helpers.keyword_path(name)
    }
  end

  def self.clear_links!
    @links = nil
  end
end
