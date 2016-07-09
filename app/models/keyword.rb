class Keyword
  def self.links
    # TODO: Clear cache.
    @links ||= TableMemo.distinct(:name).pluck(:name).each_with_object({}) {|name, h|
      h[name] = Rails.application.routes.url_helpers.keyword_path(name)
    }
  end
end
