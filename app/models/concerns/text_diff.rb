module TextDiff
  extend ActiveSupport::Concern

  included do
    def diff(old_text, new_text)
      Diffy::Diff.new(old_text.to_s.chomp + "\r\n", new_text.to_s.chomp + "\r\n").to_s
    end
  end
end
