class PopoverKeyword
  def self.keywords
    @keywords ||= Keyword.each_with_object({}) do |keyword, h|
      keywords[keyword.name] = Markdown.new(keyword.description).html
    end
  end
end
